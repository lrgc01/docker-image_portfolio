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
#
##### WARNING
#####
##### this Dockerfile is built from nodejs official Docker
##### Don't overwrite here. Using .tmp to the future.
DOCKERFILE_BODY="Dockerfile.body"
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

FROMIMG="lrgc01/ssh-debian_slim"
COMMENT="Node.js and npm over openssh-server image"
IMGNAME="nodejs"

UID_=${JENKINS_UID:-102}
GID_=${JENKINS_GID:-103}
USR_=${JENKINS_USR:-pyuser}
GRP_=${JENKINS_GRP:-pygrp}
USERDIR_=${JENKINS_HOMEDIR:-var/lib/jenkins}
USERDIR_=${USERDIR_#/}

START_CMD=${NODE_START_CMD:-"nodejs.start"}
IPFILE=${NODE_IPFILE:-"nodejs.host"}
START_DIR="/start"

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# Some environment variables that may be passed to the container
# Any file/script can be uploaded inside a volume using the Docker Host
START_SH=\${DOCKER_START_SH}
WORKDIR=\${DOCKER_WORKDIR:-"/startup.d"}

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
# ---- end workaround IP ----

# 
# ---- Dockerfile construction ----
#
# Begin head
echo "#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment=\"$COMMENT\"

RUN groupadd --gid 1000 node && \\
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node && \\
    groupadd --gid $GID_ $GRP_ && \\
    useradd -M --uid $UID_ --gid $GRP_ --shell /bin/bash -d /$USERDIR_ $USR_ && \\
    apt-get update && apt-get install -y xz-utils gpg curl && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* && \\
    mkdir -p $START_DIR

COPY $START_CMD $START_DIR/
" > $DOCKERFILE

# Body == middle
cat $DOCKERFILE_BODY >> $DOCKERFILE


# Bottom
echo "
EXPOSE 22

CMD [\"sh\",\"$START_DIR/$START_CMD\"]
" >> $DOCKERFILE
#
# ---- end Dockerfile ----
#

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

# Don't clean
#if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   ## Cleaning only if Dockerfile.tmp is the current one
   #rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
#fi

