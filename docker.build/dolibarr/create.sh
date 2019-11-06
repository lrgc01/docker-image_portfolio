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

COMMENT="Dolibarr via PHP composer on top of php-stretch_slim image"
IMGNAME="dolibarr-stretch_slim"
#FROMIMG="lrgc01/php-stretch_slim"
FROMIMG="debian3:5000/php-stretch_slim"

UID_=${DOLIB_UID:-10020}
GID_=${DOLIB_GID:-10020}
USR_=${DOLIB_USR:-"www-data"}
GRP_=${DOLIB_GRP:-"www-data"}
STARTDIR_=${DOLIB_STARTDIR:-/var/www/html}
BASEDIR_=${DOLIB_BASEDIR:-/var/www}
BASEDIR_=${BASEDIR_#/}
WORKDIR_=${DOLIB_WORKDIR:-$BASEDIR_}
WORKDIR_=${WORKDIR_#/}

START_CMD=${DOLIB_START_CMD:-"php.start"}
APPDIR=${DOLIB_APPDIR:-"dolibarr-home"}
IPFILE=${DOLIB_IPFILE:-"uwsgi.host"}

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment="$COMMENT"

RUN mkdir -p /$WORKDIR_ && \\
    chown -R $USR_ /$BASEDIR_ && \\
    set -ex && \\
    apt update -q && \\
    apt upgrade -q -y && \\
    apt install zip unzip php-xml php-curl php-mbstring php-intl php-gd composer -y -q && \\
    su -l -s /bin/bash -c "composer create-project dolibarr/dolibarr --working-dir /$WORKDIR_" $USR_ && \\
    su -l -s /bin/bash -c "composer clear-cache --working-dir /$WORKDIR_" $USR_ && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* 

VOLUME ["/$BASEDIR_"]

#CMD ["sh","/$BASEDIR_/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD 
fi

