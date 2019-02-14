#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

COMMENT="This image put together jenkins and maven into the same image"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="jenkins_maven"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

DOCKERFILE="Dockerfile.tmp"

OPTDIR="opt"
MAVEN_RUN="${OPTDIR}/maven"
MAVEN_VERSION="3.6.0"
MAVEN_BASE="apache-maven-$MAVEN_VERSION"
PACKAGE="${MAVEN_BASE}-bin.tar.gz"
CHECK="${MAVEN_BASE}-bin.tar.gz.sha512"

BASEPATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

JENKINS_PKG="jenkins_2.150.2_all.deb"

# first download packages from their sources:
# Uncomment here:
#wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/${PACKAGE}
#wget https://www.apache.org/dist/maven/maven-3/3.6.0/binaries/${CHECK}
#wget https://pkg.jenkins.io/debian-stable/binary/${JENKINS_PKG}

sha512sum $PACKAGE | diff $CHECK -
if [ "$?" -ne 0 ] ; then
  echo "sha512 sum does not match. Exiting."
  exit 1
fi

# Create directory to receive the unpacked maven
[ ! -d ${OPTDIR} ] && mkdir ${OPTDIR}
# And unpack to it
tar -xf $PACKAGE -C ${OPTDIR}
# Wipe out the extense and unique apache-maven-3.* version name
#  advocating to a cross-version name like /opt/maven
mv -f ${OPTDIR}/${MAVEN_BASE} ${MAVEN_RUN}

cat > ${DOCKERFILE} << EOF
FROM lrgc01/openjdk
LABEL Comment="$COMMENT"
ENV PATH $BASEPATH:/${MAVEN_RUN}/bin
COPY jenkins* /
COPY ${OPTDIR} /${OPTDIR}/
RUN apt-get update && \
    apt-get install -y daemon procps psmisc net-tools git && \
    dpkg -i /${JENKINS_PKG} && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    rm -f /jenkins_2*.deb
EXPOSE 8080
VOLUME ["/$MAVEN_RUN","/var/lib/jenkins"]
CMD ["/jenkins","start"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE}
