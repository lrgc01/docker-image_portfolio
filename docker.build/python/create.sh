#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

COMMENT="Python over openssh-server image"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="python3"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

DOCKERFILE="Dockerfile.tmp"

BASEPATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

UID=102
GID=103
USR=pyuser
GRP=pygrp
USRDIR=/var/lib/jenkins

cat > ${DOCKERFILE} << EOF
FROM lrgc01/minbase_stable:201902141336
LABEL Comment="$COMMENT"
RUN groupadd -g $GID $GRP && \
    useradd -M -u $UID -g $GRP -d $USRDIR $USR && \
    apt-get update && \
    apt-get install -y python3-pip && \
    apt-get clean && \
    pip3 install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    mkdir /run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE}
