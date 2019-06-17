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
IMGNAME="uwsgi-stretch_slim_ssh"
FROMIMG="lrgc01/ssh-stretch_slim"

UID_=${JENKINS_UID:-102}
GID_=${JENKINS_GID:-103}
USR_=${JENKINS_USR:-pyuser}
GRP_=${JENKINS_GRP:-pygrp}
USERDIR_=${JENKINS_HOMEDIR:-var/lib/jenkins}
USERDIR_=${USERDIR_#/}

START_CMD=${UWSGI_START_CMD:-"uwsgi.start"}
PYWSGI_CMD=${UWSGI_PYWSGI_CMD:-"wsgi_server.py"}
IPFILE=${UWSGI_IPFILE:-"uwsgi.host"}

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# workaround to get my ip
grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"

# Start the uWSGI server (must change the /$PYWSGI_CMD file to your needs)
uwsgi --http :9090 --wsgi-file /$PYWSGI_CMD --master --processes 4 --threads 2 --stats 0.0.0.0:9191

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
cat > $PYWSGI_CMD << EOF
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World"]
EOF

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment="$COMMENT"

COPY $START_CMD $PYWSGI_CMD /

RUN groupadd -g $GID_ $GRP_ && \\
    useradd -M -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    set -ex && \\
    apt-get update && \\
    apt-get install -y python-pip build-essential python-dev --no-install-recommends && \\
    apt-get clean && \\
    pip install setuptools wheel && \\
    pip install uwsgi && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* && \\
    chmod 755 /$START_CMD

# 9090 listen for connections / 9191 monitoring
EXPOSE 9090 
EXPOSE 9191

CMD ["/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD $PYWSGI_CMD
fi

