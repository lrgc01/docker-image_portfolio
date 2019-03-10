#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

OPTDIR="opt"

MAVEN_VERSION="3.6.0"
MAVEN_BASE="apache-maven-$MAVEN_VERSION"
PACKAGE="${MAVEN_BASE}-bin.tar.gz"
CHECK="${MAVEN_BASE}-bin.tar.gz.sha512"

# Optionaly this script can prepare the docker-build environment
if [ "$#" -gt 0 ]; then
   case "$1" in
      env|prepare|Dockerfile)
        DOCKERFILE="Dockerfile"
   ;;
   esac
else
   DOCKERFILE="Dockerfile.tmp"
fi

COMMENT="Maven from scratch just to share the volume of maven install"
IMGNAME="scratch_maven"

BASEPATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# first download the package from source:
if [ ! -f "$PACKAGE" ]; then
   wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/${PACKAGE}
fi
if [ ! -f "$CHECK" ]; then
   wget https://www.apache.org/dist/maven/maven-3/3.6.0/binaries/${CHECK}
fi

sha512sum $PACKAGE | diff $CHECK -
if [ "$?" -ne 0 ] ; then
  echo "sha512 sum does not match. Exiting."
  exit 1
fi

# Create directory to receive the unpacked maven
[ ! -d ${OPTDIR} ] && mkdir ${OPTDIR}

tar -xf $PACKAGE -C ${OPTDIR}
# Change versioned name to universal maven
mv ${OPTDIR}/${MAVEN_BASE} ${OPTDIR}/maven

#
# ---- Start CMD ----
#
# nope is an 'do nothing' static linked binary just to keep everything 
# clean with 0 exit code and avoid error messagens in some situations
cat > nope.c << EOF
#include <stdio.h>
#include <stdlib.h>

void main(void){
  exit(0);
}
EOF
gcc --static -o nope nope.c
#
# ---- end Start CMD ----

cat > ${DOCKERFILE} << EOF
FROM scratch
LABEL Comment="$COMMENT"
ENV PATH /${OPTDIR}/maven/bin:$BASEPATH
COPY ${OPTDIR} /opt
COPY nope /
VOLUME ["/${OPTDIR}/maven"]
CMD ["/nope"]
EOF

# Now build the image using docker build
if [ `whoami` = "root" ]; then
   docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} . 
fi
#
# ---- end docker build ----

# Cleaning
if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} nope nope.c
fi
