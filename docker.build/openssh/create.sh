#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

COMMENT="Adding openssh-client on top of base image"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="openssh"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

DOCKERFILE="Dockerfile.tmp"

cat > ${DOCKERFILE} << EOF
FROM lrgc01/minbase_stable:latest
LABEL Comment="$COMMENT"
RUN apt-get update && \
    apt-get install -y openssh-client && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 
CMD ["/usr/sbin/sshd","-D"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${DOCKERFILE}
