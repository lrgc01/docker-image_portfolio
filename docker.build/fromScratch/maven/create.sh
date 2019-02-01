#!/bin/bash

MAVEN_VERSION="3.6.0"
MAVEN_BASE="apache-maven-$MAVEN_VERSION"
PACKAGE="${MAVEN_BASE}-bin.tar.gz"
CHECK="${MAVEN_BASE}-bin.tar.gz.sha512"
# first download the package from source:
#wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/${PACKAGE}
#wget https://www.apache.org/dist/maven/maven-3/3.6.0/binaries/${CHECK}

sha512sum $PACKAGE | diff $CHECK -
if [ "$?" -ne 0 ] ; then
  echo "sha512 sum does not match. Exiting."
  exit 1
fi

# Create directory to receive the unpacked maven
[ ! -d opt ] && mkdir opt

tar -xf $PACKAGE -C opt


cat > Dockerfile << EOF
FROM scratch
ENV PATH /opt/$MAVEN_BASE/bin:$PATH
VOLUME  ["/opt/$MAVEN_BASE"]
COPY opt /
EOF
