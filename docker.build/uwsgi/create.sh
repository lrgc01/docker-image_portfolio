#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

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
IMGNAME="uwsgi-stretch_slim"
FROMIMG="lrgc01/python_dev-stretch_slim"

UID_=${UWSGI_UID:-10020}
GID_=${UWSGI_GID:-10020}
USR_=${UWSGI_USR:-uwsgi}
GRP_=${UWSGI_GRP:-uwsgi}
USERDIR_=${UWSGI_HOMEDIR:-uwsgi.d}
USERDIR_=${USERDIR_#/}

START_CMD=${UWSGI_START_CMD:-"uwsgi.start"}
PYWSGI_APP=${UWSGI_PYWSGI_APP:-"uwsgi_server.py"}
APPDIR="appdir"
PYWSGI_LOG=${UWSGI_PYWSGI_LOG:-"uwsgi.log"}
PYWSGI_INI=${UWSGI_PYWSGI_INI:-"uwsgi.ini"}
IPFILE=${UWSGI_IPFILE:-"uwsgi.host"}

#
# ---- INI file ----
#
cat > $PYWSGI_INI << EOF
[uwsgi]
# Let's use 3 connection protocols
http = :9090
uwsgi-socket = /$USERDIR_/uwsgi.sock
fastcgi-socket = /$USERDIR_/fastcgi.sock
chmod-socket = 777
# Could be a file only, but a complete app
# in a defined path is more flexible
#wsgi-file = /$USERDIR_/$APPDIR/$PYWSGI_APP
pythonpath = /$USERDIR_/$APPDIR
wsgi = ${PYWSGI_APP%.py}
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

# workaround to get my ip
grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"

# Start the uWSGI server (might change the /$USERDIR_/$PYWSGI_INI file to fit your needs)
/usr/local/bin/uwsgi /$USERDIR_/$PYWSGI_INI --daemonize2 /$USERDIR_/$PYWSGI_LOG

# then start sshd
/usr/sbin/sshd -D

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end start command ----

#
# Python uWSGI server main file
#
cat > $PYWSGI_APP << EOF
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

RUN groupadd -g $GID_ $GRP_ && \\
    useradd -m -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    mkdir -p /$USERDIR_/$APPDIR && chown -R $UID_:$GID_ /$USERDIR_/$APPDIR && \\
    set -ex && \\
    pip install setuptools wheel && \\
    pip install uwsgi && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* 

# After creating user homedir
COPY --chown=$UID_:$GID_ $START_CMD $PYWSGI_INI /$USERDIR_/
COPY --chown=$UID_:$GID_ $PYWSGI_APP /$USERDIR_/$APPDIR/

VOLUME ["/$USERDIR_"]


# 9090 listen for connections / 9191 monitoring
EXPOSE 9090 
EXPOSE 9191

CMD ["sh","/$USERDIR_/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD $PYWSGI_APP $PYWSGI_INI
fi

