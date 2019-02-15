#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

COMMENT="Adding jdk on top of base image"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="openjdk"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

DOCKERFILE="Dockerfile.tmp"

cat > ${DOCKERFILE} << EOF
FROM lrgc01/minbase_stable
LABEL Comment="$COMMENT"
RUN apt-get update && \
    apt-get install -y default-jdk-headless && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 
VOLUME ["/usr/lib/jvm"]
CMD ["/bin/bash"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${DOCKERFILE}
