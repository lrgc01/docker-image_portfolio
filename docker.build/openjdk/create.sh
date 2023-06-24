#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# The generic and then local definition
for RCFILE in "../generic.rc" "./local.rc"
do
   [ -f "$RCFILE" ] && . "$RCFILE"
done

# Folder is optional - end with a slash
FOLDER=${BASE_FOLDER:-"lrgc01/"}

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

# Comes from local.rc definition
if [ ! -z "$_DOCKERBODY" ]; then
   echo "$_DOCKERBODY" > $DOCKERFILE
fi

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
	  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi
#
# ---- end docker build ----

# Cleaning
if [ "$DOCKERFILE" != "Dockerfile" ] ; then
    # Cleaning only if Dockerfile.tmp is the current one
    rm -fr ${OPTDIR} ${DOCKERFILE} ${TAR_BALL} "$USERDIR_" usr var etc
fi

