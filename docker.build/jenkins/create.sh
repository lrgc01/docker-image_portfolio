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

COMMENT="Jenkins over base + jdk environment"
IMGNAME="jenkins"

# These are expected to be sourced from generic.rc
UID=${JENKINS_UID:-102}
GID=${JENKINS_GID:-103}
USR=${JENKINS_USR:-pyuser}
GRP=${JENKINS_GRP:-pygrp}
USERDIR=${JENKINS_HOMEDIR:-var/lib/jenkins}
# Strip out first slash
USERDIR=${USERDIR#/}
KEY_FILE=${JENKINS_KEY_FILE:-"Jenkins_System_Key"}
BASEPATH=${BASEPATH:-"/usr/local/bin:/usr/bin:/usr/sbin"}
LOCALBIN=${JENKINS_LOCALBIN:-"usr/local/bin"}

# Temporary tarball to ADD into the container
TAR_BALL=temp_tarball.tgz

# This has to be always checked - use direct download because 
# the download from apt repo is to slow
JENKINS_PKG="jenkins_2.150.2_all.deb"
if [ ! -f "$JENKINS_PKG" ]; then
   wget https://pkg.jenkins.io/debian-stable/binary/${JENKINS_PKG}
fi

# Pre build of some directory trees
#
# ---- SSH configuration ----
#
if [ ! -d "$USERDIR" ]; then
   mkdir -p "$USERDIR" 
fi
mkdir -p "$USERDIR"/.ssh
ssh-keygen -f "$USERDIR/.ssh/$KEY_FILE" -N ''
cp "$USERDIR/.ssh/$KEY_FILE".pub "$USERDIR"/.ssh/authorized_keys
# ssh config to use widely
cat > "$USERDIR"/.ssh/config << EOF
Host *
IdentityFile ~/.ssh/$KEY_FILE
User $USR
StrictHostKeyChecking no
EOF
# Proper settings to ensure ssh running
chown -R $UID:$GID "$USERDIR"
chmod -R go-rwx "$USERDIR"
#
# ---- end SSH ----

# 
# ---- other user configs ----
echo export PATH=$BASEPATH > "$USERDIR"/.profile
echo export PATH=$BASEPATH > "$USERDIR"/.bashrc
chown $UID:$GID "$USERDIR"/.profile
chown $UID:$GID "$USERDIR"/.bashrc
# ---- end configs ----

# 
# ---- Python wrapper built in bash ----
#
# This will be used by jenkins to find out the python host
PYHOST_FILE=${JENKINS_PYHOST_FILE:-"python.host"}
PYWRAP_FILE=${JENKINS_PYWRAP_FILE:-"py_wrap.sh"}
# python commands to be linked to $PYWRAP_FILE
PYFILES="python python3 pytest py.test pyinstaller"

if [ ! -d $LOCALBIN ]; then
   mkdir -p $LOCALBIN
fi
cat > $LOCALBIN/$PYWRAP_FILE << EOF
#!/bin/sh

if [ -f ~/$PYHOST_FILE ]; then
   PYHOST=\$(cat ~/$PYHOST_FILE)
else
   echo "Could not determine python server IP. No ~/$PYHOST_FILE file."
   exit 1
fi

CWD="\`pwd\`"		# Should run in the same directory
COMMAND=\`basename \$0\`	# Just want the command name itself

if [ "\$COMMAND" = "python" ] ; then
   # If need python2, remove this IF but install python2 in the python container
   ssh -o StrictHostKeyChecking=no \$PYHOST "(cd \"\$CWD\" ; python3 "\$@" )"
else
   ssh -o StrictHostKeyChecking=no \$PYHOST "(cd \"\$CWD\" ; \$COMMAND "\$@" )"
fi

EOF

# Don't forget to make it executable
chmod 755 $LOCALBIN/$PYWRAP_FILE

( cd $LOCALBIN 
for pyfile in $PYFILES
do
   ln -sf $PYWRAP_FILE $pyfile
done )
#
# ---- end python wrap ----

#
# ---- The jenkins CMD to start container ----
cp jenkins $LOCALBIN
#
# ---- end jenkins CMD ----

# Make tar ball
tar -czf ${TAR_BALL} "$USERDIR" usr 

# 
# ---- Finally run docker build ----
#
cat > ${DOCKERFILE} << EOF
FROM lrgc01/openjdk
LABEL Comment="$COMMENT"
COPY jenkins_* /
ADD $TAR_BALL /
RUN groupadd -g $GID $GRP && \
    useradd -M -u $UID -g $GRP -d /$USERDIR $USR && \
    apt-get update && \
    apt-get install -y daemon procps psmisc net-tools git && \
    apt-get clean && \
    dpkg -i /jenkins_2.150.2_all.deb ; \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    rm -f /jenkins_*.deb 
EXPOSE 8080
VOLUME  ["/$USERDIR"]
CMD ["/$LOCALBIN/jenkins","start"]
EOF

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
#
# ---- end docker build ----

# Cleaning
rm -fr ${OPTDIR} ${DOCKERFILE} ${TAR_BALL} "$USERDIR" usr var
