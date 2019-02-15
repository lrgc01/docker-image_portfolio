#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

COMMENT="Jenkins over base + jdk environment"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="jenkins"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

DOCKERFILE="Dockerfile.tmp"

cat > ${DOCKERFILE} << EOF
FROM lrgc01/minbase_stable_debian9
LABEL Comment="$COMMENT"
COPY jenkins* /
COPY profile /etc/
RUN apt-get update && \
    apt-get install -y daemon procps psmisc net-tools git && \
    apt-get clean && \
    dpkg -i /jenkins_2.150.2_all.deb ; \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    rm -f /jenkins_2*.deb
EXPOSE 8080
VOLUME  ["/var/lib/jenkins"]
CMD ["/jenkins","start"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE}
