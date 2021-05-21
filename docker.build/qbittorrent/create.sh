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

COMMENT="qbittorrent using python3-dev image"
IMGNAME="qbittorrent"
FROMIMG="lrgc01/python3-pip"

UID_=${QBITTORRENT_UID:-1000}
GID_=${QBITTORRENT_GID:-1000}
USR_=${QBITTORRENT_USR:-qbittorrent}
GRP_=${QBITTORRENT_GRP:-qbittorrent}
USERDIR_=${QBITTORRENT_HOMEDIR:-data}
USERDIR_=${USERDIR_#/}

START_CMD=${QBITTORRENT_START_CMD:-"start.sh"}
START_SCRIPT=${QBITTORRENT_START_SCRIPT:-"qbittorrent.sh"}
START_DIR=${QBITTORRENT_START_DIR:-"/$USERDIR_"}
IPFILE=${QBITTORRENT_IPFILE:-"host.ip"}

# 
# ---- Start command ----
#   start script is relative to workdir
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# Some environment variables that may be passed to the container
# Any file/script can be uploaded inside a volume using the Docker Host
START_SH=\${DOCKER_START_SH:-"$START_SCRIPT"}
WORKDIR=\${DOCKER_WORKDIR:-"$START_DIR"}

# Start of the container main purpose app
if [ -d "\$WORKDIR" ]; then
   cd "\$WORKDIR"
fi

# If there is a application script, run it, otherwise run sshd below
if [ -f "\$START_SH" ]; then
   bash "\$START_SH"
else
   if [ -d "/$USERDIR_" ];  then
      # workaround to get my ip
      grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"
   fi
   # -D to run the daemon in foreground
   /usr/sbin/sshd -D
fi

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
    groupadd -g $GID_ $GRP_ && \\
    useradd -M -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    apt-get update && \\
    apt-get install -y qbittorrent-nox --no-install-recommends && \\
    apt-get clean && \\
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
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD $PYWSGI_APP $PYWSGI_INI
fi

