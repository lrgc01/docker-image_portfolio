#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="scratch_maven"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

OPTDIR="opt"

MAVEN_VERSION="3.6.0"
MAVEN_BASE="apache-maven-$MAVEN_VERSION"
PACKAGE="${MAVEN_BASE}-bin.tar.gz"
CHECK="${MAVEN_BASE}-bin.tar.gz.sha512"

DOCKERFILE="Dockerfile.tmp"

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


cat > ${DOCKERFILE} << EOF
FROM scratch
LABEL Comment="This image is used just to share the volume of maven install"
ENV PATH /${OPTDIR}/maven/bin:$BASEPATH
COPY ${OPTDIR} /opt
VOLUME ["/${OPTDIR}/maven"]
CMD ["/#noop"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} . 

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE}
