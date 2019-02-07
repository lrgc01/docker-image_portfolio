#!/bin/bash

WORKDIR="`dirname $0`"

cd "$WORKDIR"

OPTDIR="opt"

MAVEN_VERSION="3.6.0"
MAVEN_BASE="apache-maven-$MAVEN_VERSION"
PACKAGE="${MAVEN_BASE}-bin.tar.gz"
CHECK="${MAVEN_BASE}-bin.tar.gz.sha512"

BUILD_VER=$(date +%Y%m%d%H%M)

BASEPATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# first download the package from source:
#wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/${PACKAGE}
#wget https://www.apache.org/dist/maven/maven-3/3.6.0/binaries/${CHECK}

sha512sum $PACKAGE | diff $CHECK -
if [ "$?" -ne 0 ] ; then
  echo "sha512 sum does not match. Exiting."
  exit 1
fi

# Create directory to receive the unpacked maven
[ ! -d ${OPTDIR} ] && mkdir ${OPTDIR}

tar -xf $PACKAGE -C ${OPTDIR}


cat > Dockerfile << EOF
FROM lrgc01/jre
ENV PATH /${OPTDIR}/$MAVEN_BASE/bin:$BASEPATH
COPY ${OPTDIR} /opt
RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 
VOLUME ["/${OPTDIR}/$MAVEN_BASE"]
EXPOSE 22
CMD ["/etc/init.d/ssh","start","-D"]
EOF

# Now build the image using docker build
docker build -t lrgc01/maven:${BUILD_VER} .

# Cleaning
rm -fr ${OPTDIR}
