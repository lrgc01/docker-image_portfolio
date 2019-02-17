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

DOCKERFILE="Dockerfile.tmp"

COMMENT="Python over openssh-server image"
IMGNAME="python3"

UID=${JENKINS_UID:-102}
GID=${JENKINS_GID:-103}
USR=${JENKINS_USR:-pyuser}
GRP=${JENKINS_GRP:-pygrp}
USERDIR=${JENKINS_HOMEDIR:-var/lib/jenkins}
USERDIR=${USERDIR#/}

START_CMD=${PY_START_CMD:-"python.start"}
IPFILE=${PY_IPFILE:-"python.host"}

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# workaround to get my ip
grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR/$IPFILE"
# then start sshd
/usr/sbin/sshd -D

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
FROM lrgc01/minbase_stable_ssh
LABEL Comment="$COMMENT"
COPY $START_CMD /
RUN groupadd -g $GID $GRP && \
    useradd -M -u $UID -g $GRP -d /$USERDIR $USR && \
    apt-get update && \
    apt-get install -y python3-pip && \
    apt-get clean && \
    pip3 install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    chmod 755 /$START_CMD
EXPOSE 22
CMD ["/$START_CMD"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
