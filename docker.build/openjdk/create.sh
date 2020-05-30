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

COMMENT="Adding jdk on top of base image"

# Folder is optional - end with a slash
IMGNAME="openjdk"
FROMIMG="lrgc01/ssh-debian_slim"

# 
# Dockerfile
#
cat > ${DOCKERFILE} << EOF
FROM $FROMIMG

LABEL Comment="$COMMENT"

# Workaround to avoid install error when linking man page
RUN apt-get update && \\
    mkdir -p /usr/share/man/man1 ; \\
    apt-get install -y default-jdk-headless && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -f /var/lib/apt/lists/*debian.org* && \\
    rm -fr /usr/share/man/man*/*

VOLUME ["/usr/lib/jvm"]

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
EOF

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

