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

COMMENT="Ruby over openssh-server image"
IMGNAME="ruby-strech_slim"
FROMIMG="lrgc01/ssh-debian_slim"

UID_=${JENKINS_UID:-102}
GID_=${JENKINS_GID:-103}
USR_=${JENKINS_USR:-rbuser}
GRP_=${JENKINS_GRP:-rbgrp}
USERDIR_=${JENKINS_HOMEDIR:-var/lib/jenkins}
USERDIR_=${USERDIR_#/}

START_CMD=${RUBY_START_CMD:-"ruby.start"}
IPFILE=${RUBY_IPFILE:-"ruby.host"}
START_DIR="/start"

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# workaround to get my ip
grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"
# then start sshd
/usr/sbin/sshd -D

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

RUN groupadd --gid $GID_ $GRP_ && \\
    useradd -M --uid $UID_ -gid $GRP_ -s /bin/bash -d /$USERDIR_ $USR_ && \\
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

if [ "$DOCKERFILE" != "Dockerfile"  -a $BUILD_ENV != "1" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
fi

