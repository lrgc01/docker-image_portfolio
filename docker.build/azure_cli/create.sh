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

ARCH=$(dpkg --print-architecture)

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

COMMENT="Azure linux CLI over openssh-server image"
IMGNAME="azure_cli"
FROMIMG="lrgc01/ssh-stable_slim:${ARCH}"

UID_=${AZURE_UID:-10001}
GID_=${AZURE_GID:-10001}
USR_=${AZURE_USR:-azusr}
GRP_=${AZURE_GRP:-azgrp}
USERDIR_=${AZURE_HOMEDIR:-home/azure}
USERDIR_=${USERDIR_#/}
USERPASS_=`echo "DockerAz123" | openssl passwd -1 -stdin`

#START_CMD=${AZ_START_CMD:-"/bin/bash"}

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
FROM $FROMIMG

LABEL Comment="$COMMENT"

RUN groupadd -g $GID_ $GRP_ && \\
    useradd -u $UID_ -g $GRP_ -m -d /$USERDIR_ -s /bin/bash -p '$USERPASS_' $USR_ && \\
    apt-get update && \\
    apt-get install -y curl gnupg2 apt-transport-https lsb-release software-properties-common dirmngr ca-certificates --no-install-recommends && \\
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \\
    AZ_REPO=\$(lsb_release -cs) && \\
    echo "deb [arch=${ARCH}] https://packages.microsoft.com/repos/azure-cli/ \$AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list && \\
    apt-get update && \\
    apt-get install -y azure-cli --no-install-recommends && \\
    apt-get remove -y --autoremove curl gnupg2 apt-transport-https lsb-release software-properties-common dirmngr ca-certificates && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -f /var/lib/apt/lists/*debian.org* && \\
    rm -fr /usr/share/man/man*/* 

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]

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
   rm -fr ${DOCKERFILE} 
fi
