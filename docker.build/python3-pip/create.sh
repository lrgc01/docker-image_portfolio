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

# Optionaly this script can prepare the docker-build environment
if [ "$#" -gt 0 ]; then
   case "$1" in
      env|prepare|Dockerfile)
	BUILD_ENV="1"
        DOCKERFILE="Dockerfile"
   ;;
   esac
else
   DOCKERFILE="Dockerfile.tmp"
fi

COMMENT="python3-pip over openssh-server image"
IMGNAME="python3-pip"
#FROMIMG="lrgc01/ssh-stable_slim"

UID_=${PYTHON3_UID:-10020}
GID_=${PYTHON3_GID:-10020}
USR_=${PYTHON3_USR:-pyusr}
GRP_=${PYTHON3_GRP:-pygrp}
USERDIR_=${PYTHON3_HOMEDIR:-conf.d}
USERDIR_=${USERDIR_#/}

START_CMD=${PYTHON3_START_CMD:-"start.sh"}
START_DIR=${PYTHON3_START_DIR:-"/start"}
IPFILE=${PYTHON3_IPFILE:-"host.ip"}

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# workaround to get my ip
grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "$START_DIR/$IPFILE"

/usr/sbin/sshd -D

EOF

# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end start command ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment="$COMMENT"

RUN set -ex && \\
    apt-get update && \\
    apt-get install -y python3-pip --no-install-recommends && \\
    apt-get clean && \\
    pip3 install setuptools wheel && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* && \\
    mkdir -p $START_DIR

COPY $START_CMD $START_DIR/

CMD ["sh","$START_DIR/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
  if [ $? -eq 0 ]; then
     docker image tag ${FOLDER}${IMGNAME}${BUILD_VER} ${FOLDER}${IMGNAME}:${ARCH} 
     docker image rm ${FOLDER}${IMGNAME}${BUILD_VER}
  fi
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD $PYWSGI_APP $PYWSGI_INI
fi

