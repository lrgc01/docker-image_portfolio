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

COMMENT="Jenkins over base + jdk environment"
IMGNAME="jenkins"

# These are expected to be sourced from generic.rc
UID_=${JENKINS_UID:-102}
GID_=${JENKINS_GID:-103}
USR_=${JENKINS_USR:-pyuser}
GRP_=${JENKINS_GRP:-pygrp}
USERDIR_=${JENKINS_HOMEDIR:-var/lib/jenkins}
# Strip out first slash
USERDIR_=${USERDIR_#/}
KEY_FILE=${JENKINS_KEY_FILE:-"Jenkins_System_Key"}
BASEPATH=${BASEPATH:-"/usr/local/bin:/usr/local/sbin:/opt/maven/bin:/usr/bin:/usr/sbin:/bin:/sbin"}
LOCALBIN=${JENKINS_LOCALBIN:-"usr/local/bin"}
JENKINS_WAR=${JENKINS_WAR:-"/usr/share/jenkins/jenkins.war"}

# Temporary tarball to ADD into the container
TAR_BALL=temp_tarball.tgz

#
# ---- Jenkins tree ----
#
# This has to be always checked - use direct download because 
# the download from apt repo is to slow
JENKINS_PKG="jenkins_2.176.2_all.deb"
if [ ! -f "$JENKINS_PKG" ]; then
   wget https://pkg.jenkins.io/debian-stable/binary/${JENKINS_PKG}
fi
# Extracted contents go into tarball
dpkg -x ${JENKINS_PKG} .
#
# ---- end Jenkins tree ----

# Pre build of some directory trees
#
# ---- SSH configuration ----
#
if [ ! -d "$USERDIR_" ]; then
   mkdir -p "$USERDIR_" 
fi
mkdir -p "$USERDIR_"/.ssh
ssh-keygen -f "$USERDIR_/.ssh/$KEY_FILE" -N ''
cp "$USERDIR_/.ssh/$KEY_FILE".pub "$USERDIR_"/.ssh/authorized_keys
# ssh config to use widely
cat > "$USERDIR_"/.ssh/config << EOF
Host *
IdentityFile ~/.ssh/$KEY_FILE
User $USR_
StrictHostKeyChecking no
EOF
# Proper settings to ensure ssh running
chown -R $UID_:$GID_ "$USERDIR_"
chmod -R go-rwx "$USERDIR_"
#
# ---- end SSH ----

# 
# ---- other user configs ----
echo export PATH=$BASEPATH > "$USERDIR_"/.profile
echo export PATH=$BASEPATH > "$USERDIR_"/.bashrc
chown $UID_:$GID_ "$USERDIR_"/.profile
chown $UID_:$GID_ "$USERDIR_"/.bashrc
# ---- end configs ----

# 
# ---- Python wrapper built in bash ----
#
# This will be used by jenkins to find out the python host
PYHOST_FILE=${PYHOST_FILE:-"python.host"}
PYWRAP_FILE=${PYWRAP_FILE:-"py_wrap.sh"}
# python commands to be linked to $PYWRAP_FILE
PYFILES="python python3 pytest py.test pyinstaller"

if [ ! -d $LOCALBIN ]; then
   mkdir -p $LOCALBIN
fi
cat > $LOCALBIN/$PYWRAP_FILE << EOF
#!/bin/sh

if [ -f ~/$PYHOST_FILE ]; then
   PYHOST=\$(head -1 ~/$PYHOST_FILE)
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
# ---- Node.js wrapper commands in bash ----
#
# This will be used by jenkins to find out the node.js host
NODE_HOST_FILE=${NODE_HOST_FILE:-"nodejs.host"}
NODE_WRAP_FILE=${NODE_WRAP_FILE:-"nodejs_wrap.sh"}
# python commands to be linked to $PYWRAP_FILE
NODE_FILES="node npm "

if [ ! -d $LOCALBIN ]; then
   mkdir -p $LOCALBIN
fi
cat > $LOCALBIN/$NODE_WRAP_FILE << EOF
#!/bin/sh

if [ -f ~/$NODE_HOST_FILE ]; then
   NODE_HOST=\$(head -1 ~/$NODE_HOST_FILE)
else
   echo "Could not determine python server IP. No ~/$NODE_HOST_FILE file."
   exit 1
fi

CWD="\`pwd\`"		# Should run in the same directory
COMMAND=\`basename \$0\`	# Just want the command name itself

ssh -o StrictHostKeyChecking=no \$NODE_HOST "(cd \"\$CWD\" ; \$COMMAND "\$@" )"

EOF

# Don't forget to make it executable
chmod 755 $LOCALBIN/$NODE_WRAP_FILE

( cd $LOCALBIN 
for nodefile in $NODE_FILES
do
   ln -sf $NODE_WRAP_FILE $nodefile
done )
#
# ---- end Node.js wrap ----

# 
# ---- PHP wrapper commands in bash ----
#
# This will be used by jenkins to find out the PHP host
PHP_HOST_FILE=${PHP_HOST_FILE:-"php.host"}
PHP_WRAP_FILE=${PHP_WRAP_FILE:-"php_wrap.sh"}
# PHP commands to be linked to $PHP_WRAP_FILE
PHP_FILES="php phpdismod phpenmod phpquery "

if [ ! -d $LOCALBIN ]; then
   mkdir -p $LOCALBIN
fi
cat > $LOCALBIN/$PHP_WRAP_FILE << EOF
#!/bin/sh

if [ -f ~/$PHP_HOST_FILE ]; then
   PHP_HOST=\$(head -1 ~/$PHP_HOST_FILE)
else
   echo "Could not determine PHP server IP. No ~/$PHP_HOST_FILE file."
   exit 1
fi

CWD="\`pwd\`"		# Should run in the same directory
COMMAND=\`basename \$0\`	# Just want the command name itself

ssh -o StrictHostKeyChecking=no \$PHP_HOST "(cd \"\$CWD\" ; \$COMMAND "\$@" )"

EOF

# Don't forget to make it executable
chmod 755 $LOCALBIN/$PHP_WRAP_FILE

( cd $LOCALBIN 
for phpfile in $PHP_FILES
do
   ln -sf $PHP_WRAP_FILE $phpfile
done )
#
# ---- end PHP wrap ----

#
# ---- The jenkins CMD to start container ----
cat > $LOCALBIN/jenkins << EOF
#!/bin/bash

PATH=$BASEPATH
export PATH
umask 022
java -jar $JENKINS_WAR --httpPort=8080
EOF
chmod 755 $LOCALBIN/jenkins
#
# ---- end jenkins CMD ----

# Make tar ball that will contain usr and var trees
tar -czf ${TAR_BALL} usr etc var
# may add USERDIR_ when it is not inside var
#tar -czf ${TAR_BALL} usr etc var "${USERDIR_}"
# 
# ---- Finally run docker build ----
#
cat > ${DOCKERFILE} << EOF
FROM lrgc01/openjdk
LABEL Comment="$COMMENT"
ADD $TAR_BALL /
RUN groupadd -g $GID_ $GRP_ && \\
    useradd -M -u $UID_ -g $GRP_ -d /$USERDIR_ $USR_ && \\
    apt-get update && \\
    apt-get install -y git && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -f /var/lib/apt/lists/*debian.org* && \\
    rm -fr /usr/share/man/man* 
EXPOSE 8080
VOLUME  ["/$USERDIR_"]
CMD ["/$LOCALBIN/jenkins"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi
#
# ---- end docker build ----

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} ${TAR_BALL} "$USERDIR_" usr var etc
fi

