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

COMMENT="PHP composer on top of php-stretch_slim image"
IMGNAME="php_composer-stretch_slim"
#FROMIMG="lrgc01/php-stretch_slim"
FROMIMG="debian3:5000/php-stretch_slim"

UID_=${PHPCOMP_UID:-10020}
GID_=${PHPCOMP_GID:-10020}
USR_=${PHPCOMP_USR:-"www-data"}
GRP_=${PHPCOMP_GRP:-"www-data"}
STARTDIR_=${PHPCOMP_STARTDIR:-/var/www/html} # not used by now
BASEDIR_=${PHPCOMP_BASEDIR:-/data}
BASEDIR_=${BASEDIR_#/}
WORKDIR_=${PHPCOMP_WORKDIR:-$BASEDIR_/work}
WORKDIR_=${WORKDIR_#/}

START_CMD=${PHPCOMP_START_CMD:-"php.start"}
APPDIR=${PHPCOMP_APPDIR:-"home"}
IPFILE=${PHPCOMP_IPFILE:-"php_composer.host"}

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
    apt install zip unzip php-xml php-curl php-mbstring php-intl php-gd composer php-zip php-mcrypt -y -q --no-install-recommends && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* 

VOLUME ["/$WORKDIR_"]

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

