#!/bin/bash

BUILDDIR="`dirname $0`"
cd "$BUILDDIR"

# The generic definition
[ -f ../generic.rc ] && . ../generic.rc

# Folder is optional - end with a slash
FOLDER=${BASE_FOLDER:-"lrgc01/"}
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=${GLOBAL_TAG_VER:-$(date +:%Y%m%d%H%M)}

# Optionaly this script can prepare the docker-build environment
if [ "$#" -gt 0 ]; then
   case "$1" in
      env|prepare|Dockerfile)
	BUILD_ENV="1"
        DOCKERFILE="Dockerfile"
   ;;
   esac
else
   DOCKERFILE="Dockerfile.tmp"
fi

COMMENT="uWSGI via pip over openssh-server image"
IMGNAME="uwsgi"
FROMIMG="lrgc01/python3-dev"

UID_=${UWSGI_UID:-10020}
GID_=${UWSGI_GID:-10020}
USR_=${UWSGI_USR:-uwsgi}
GRP_=${UWSGI_GRP:-uwsgi}
STARTDIR_=${UWSGI_STARTDIR:-uwsgi.d}
BASEDIR_=${UWSGI_BASEDIR:-uwsgi.d}
BASEDIR_=${BASEDIR_#/}
USERDIR_=${UWSGI_HOMEDIR:-$BASEDIR_/uwsgi}
USERDIR_=${USERDIR_#/}

START_CMD=${UWSGI_START_CMD:-"uwsgi.start"}
UWSGI_APP=${UWSGI_UWSGI_APP:-"uwsgi_server.py"}
APPDIR=${UWSGI_APPDIR:-"appdir"}
UWSGI_LOG=${UWSGI_UWSGI_LOG:-"uwsgi.log"}
UWSGI_SOCK=${UWSGI_UWSGI_SOCK:-"uwsgi.sock"}
UWSGI_FSOCK=${UWSGI_UWSGI_FSOCK:-"fastcgi.sock"}
UWSGI_INI=${UWSGI_UWSGI_INI:-"uwsgi.ini"}
IPFILE=${UWSGI_IPFILE:-"uwsgi.host"}

#
# ---- INI file ----
#
cat > $UWSGI_INI << EOF
[uwsgi]
# Let's use 3 connection protocols
http = :9090
uwsgi-socket = /$BASEDIR_/$UWSGI_SOCK
fastcgi-socket = /$BASEDIR_/$UWSGI_FSOCK
chmod-socket = 777
# Could be a file only, but a complete app
# in a defined path is more flexible
#wsgi-file = /$BASEDIR_/$APPDIR/$UWSGI_APP
pythonpath = /$BASEDIR_/$APPDIR
wsgi = ${UWSGI_APP%.py}
master = true
processes = 4
threads = 2
stats = 0.0.0.0:9191
uid = $USR_
gid = $GRP_
EOF

#
# ---- end INI file ----

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

THIS="\$0"

export BASEDIR=\${DOCKER_BASEDIR:-"/$BASEDIR_"}
export RUNUSER=\${DOCKER_RUNUSER:-"$USR_"}

export UWSGI_DAEMON="no"

cd \$BASEDIR

if [ \$(whoami)x = "rootx" ] ; then
   export UWSGI_DAEMON="yes"
   env > environment.rc
   su -l \$RUNUSER -s /bin/bash -c "sh \$THIS \$*"
   # then start sshd as root
   /usr/sbin/sshd -D
   exit 0
fi

#set -x

[ -f "./environment.rc" ] && . ./environment.rc
export HOME=\$BASEDIR
export WORKDIR=\$BASEDIR


#
# Receive (or not) some env variables from Docker container
# All of them start with DOCKER_
# The "UWSGI" ones go into INI file
#
START_CMD=\${DOCKER_START_CMD:-"$START_CMD"}
UWSGI_SOCK=\${DOCKER_UWSGI_SOCK:-"$UWSGI_SOCK"}
UWSGI_FSOCK=\${DOCKER_UWSGI_FSOCK:-"$UWSGI_FSOCK"}
UWSGI_LOG=\${DOCKER_UWSGI_LOG:-"$UWSGI_LOG"}
UWSGI_HTTP=\${DOCKER_UWSGI_HTTP:-"0.0.0.0:9090"}
UWSGI_APP=\${DOCKER_UWSGI_APP:-"$UWSGI_APP"}
UWSGI_APPDIR=\${DOCKER_UWSGI_APPDIR:-"/$BASEDIR_/$APPDIR"}
UWSGI_INI=\${DOCKER_UWSGI_INI:-"$UWSGI_INI"}
UWSGI_PROCESSES=\${DOCKER_UWSGI_PROCESSES:-"4"}
UWSGI_THREADS=\${DOCKER_UWSGI_THREADS:-"2"}
UWSGI_STATS=\${DOCKER_UWSGI_STATS:-"0.0.0.0:9191"}
USERDIR=\${DOCKER_USERDIR:-"/$USERDIR_"}
CONFIGDIR=\${DOCKER_CONFIGDIR:-"/$BASEDIR_"}
LOGDIR=\${DOCKER_LOGDIR:-"/$BASEDIR_"}
USR_=\${DOCKER_UWSGI_USR:-"$USR_"}
GRP_=\${DOCKER_UWSGI_GRP:-"$GRP_"}


# Make sure every directory is ready to do the job
mkdir -p \$USERDIR \$CONFIGDIR \$LOGDIR > /dev/null 2>&1

#
# ---- Build INI file ----
#

cat > \$CONFIGDIR/\$UWSGI_INI << ENDOF
[uwsgi]
# Let's use 3 connection protocols
http = \$UWSGI_HTTP
uwsgi-socket = \$BASEDIR/\$UWSGI_SOCK
fastcgi-socket = \$BASEDIR/\$UWSGI_FSOCK
chmod-socket = 777
# Could be a file only, but a complete app
# in a defined path is more flexible
#wsgi-file = \$UWSGI_APPDIR/\$UWSGI_APP
pythonpath = \$UWSGI_APPDIR
wsgi = \${UWSGI_APP%.py}
master = true
processes = \$UWSGI_PROCESSES
threads = \$UWSGI_THREADS
stats = \$UWSGI_STATS
uid = \$USR_
gid = \$GRP_
ENDOF
#
# ---- end INI file ----

# workaround to get my ip (head -1 = in case of duplicates)
grep -w \$(hostname) /etc/hosts | head -1 | awk '{print \$1}' > "\$BASEDIR/$IPFILE"

# Start the uWSGI server (might change the /\$CONFIGDIR/\$UWSGI_INI file to fit your needs)
if [ "\$UWSGI_DAEMON" = "yes" ]; then 
   /usr/local/bin/uwsgi \$CONFIGDIR/\$UWSGI_INI --daemonize2 \$LOGDIR/\$UWSGI_LOG
else
   /usr/local/bin/uwsgi \$CONFIGDIR/\$UWSGI_INI 
fi

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end start command ----

#
# Python uWSGI server main file
#
cat > $UWSGI_APP << EOF
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return ["Congrats! Your Python App Web server is working!\n"]
EOF
#
# ---- end uWSGI server file ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment="$COMMENT"

RUN mkdir -p /$BASEDIR_ && \\
    groupadd -g $GID_ $GRP_ && \\
    useradd -m -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    mkdir -p /$BASEDIR_/$APPDIR && chown -R $UID_:$GID_ /$BASEDIR_ && \\
    set -ex && \\
    pip3 install uwsgi && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* 

# After creating user homedir
COPY --chown=$UID_:$GID_ $START_CMD $UWSGI_INI /$BASEDIR_/
COPY --chown=$UID_:$GID_ $UWSGI_APP /$BASEDIR_/$APPDIR/

VOLUME ["/$BASEDIR_"]


# 9090 listen for connections / 9191 monitoring
EXPOSE 9090 
EXPOSE 9191

CMD ["sh","/$BASEDIR_/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD $UWSGI_APP $UWSGI_INI
fi

