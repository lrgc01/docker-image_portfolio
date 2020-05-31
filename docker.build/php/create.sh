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

COMMENT="PHP and php-fpm software + server over openssh-server image"
IMGNAME="php-stretch_slim_ssh"

# Not used, just in case ...
UID_=${JENKINS_UID:-102}
GID_=${JENKINS_GID:-103}
USR_=${JENKINS_USR:-pyuser}
GRP_=${JENKINS_GRP:-pygrp}
# This is globally used
USERDIR_=${JENKINS_HOMEDIR:-var/lib/jenkins}
USERDIR_=${USERDIR_#/}

START_CMD=${PHP_START_CMD:-"php.start"}
IPFILE=${PHP_IPFILE:-"php.host"}
START_DIR=${PHP_START_DIR:-"/start"}

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# Some environment variables that may be passed to the container
# Any file/script can be uploaded inside a volume using the Docker Host
START_SH=\${DOCKER_START_SH}
WORKDIR=\${DOCKER_WORKDIR:-"/startup.d"}

# First start the fpm server as a daemon
/usr/sbin/php-fpm7.0 --daemonize --fpm-config /etc/php/7.0/fpm/php-fpm.conf

# Start of the container main purpose app
if [ -d "\$WORKDIR" ]; then
   cd "\$WORKDIR"
fi

# If there is a application script, run it, otherwise run sshd below
if [ -f "\$START_SH" ]; then
   bash "\$START_SH"
else
   if [ -d "/$USERDIR_" ];  then
      # workaround to get my ip
      grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"
   fi
   # -D to run the daemon in foreground
   /usr/sbin/sshd -D
fi

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="$COMMENT"

RUN groupadd -g $GID_ $GRP_ && \\
    useradd -M -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    set -ex && \\
    apt-get update && \\
    apt-get install -q -y php php-fpm php-mysql php-gd php-curl php-mbstring php-intl php-xml php-mcrypt php-zip --no-install-recommends && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man*/* && \\
    mkdir -p /run/php $START_DIR

COPY $START_CMD $START_DIR/

# If someone wants TCP instead of socket
EXPOSE 9000

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/run/php","/etc/php"]

CMD ["sh","$START_DIR/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
fi

