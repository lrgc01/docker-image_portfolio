#!/bin/bash

Usage() {
        echo "Build image or make env to build"
	echo "Usage: $0 -p <prepare env (Dockerfile,etc)> -f <use alternate name for Dockerfile> -t <tag image as> -d (Dry Run - no arg)"
}

EXITCODE=0

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# The generic and then local definition
for RCFILE in "../scripts/generic.rc" "./local.rc"
do
	if [ -f "$RCFILE" ]; then
	       	. "$RCFILE" 
	else
		echo $RCFILE not found 
	       	exit 2
	fi
done

# Folder is optional - end with a slash
FOLDER=${BASE_FOLDER:-"lrgc01/"}
_TAGLATEST="${FOLDER%/}/$_TAG"

if [ `whoami` != "root" ]; then
        SUDO="sudo"
fi

DOCKERFILE="Dockerfile.tmp"

while [ $# -gt 0 ]
do
   case $1 in
      -[fF]) DOCKERFILE="$2"
          shift 2
      ;;
      -[tT]) _TAG="$2"
          shift 2
      ;;
      --[pP][rR][eE][pP][aA]*|-[pP]) 
          BUILD_ENV="1"
          DOCKERFILE="Dockerfile"
          shift 1
      ;;
      --[dD][rR][yY]-[rR][uU][nN]|-[dD]) 
          DRYRUN='echo [DryRun] Would run:'
          _MINUSD="-d"
          shift 1
      ;;
      --[hH][eE][lL][pP]|-[hH])
          Usage
          exit
      ;;
      *) shift
      ;;
   esac
done

# Comes from local.rc definition
if [ ! -z "$_DOCKERBODY" ]; then
   echo "$_DOCKERBODY" > $DOCKERFILE
fi
if [ ! -z "$_STARTBODY" ]; then
   echo "$_STARTBODY" > $STARTFILE
   chmod 755 $STARTFILE
fi

PULLIMG=$(grep -e "^FROM " $DOCKERFILE | sed -e 's/FROM //')
UPTODATE=$($DRYRUN $SUDO docker pull $PULLIMG | grep -e 'up to date')

NEWID=$(CheckImgDependency -l $LASTIDFILE -f $DOCKERFILE $_MINUSD)
DIFFLASTID=$?

if [ ! -z "$UPTODATE" -a "$DIFFLASTID" -eq 0 ]; then
        echo "No need to update container chain"
        EXITCODE=111
else
	# Now build the image using docker build only if root is running
	if [ "$BUILD_ENV" != "1" ]; then
		$DRYRUN $SUDO docker build -t ${FOLDER}${_TAG}${BUILD_VER} -f ${DOCKERFILE} .
		if [ $? -eq 0 ]; then
			$DRYRUN $SUDO docker image tag ${FOLDER}${_TAG}${BUILD_VER} $_TAGLATEST
			$DRYRUN $SUDO docker image rm ${FOLDER}${_TAG}${BUILD_VER}
           		$DRYRUN $SUDO docker push $_TAGLATEST
			if [ ! -z "$DRYRUN" ]; then
           			$DRYRUN echo $NEWID 
			else
           			echo $NEWID > $LASTIDFILE
			fi
           		$DRYRUN $SUDO docker image prune -f
		fi
		# Cleaning
		rm -fr ${OPTDIR} ${DOCKERFILE} ${TOCLEAN} "$USERDIR_" usr var etc
	fi
fi
# ---- end docker build ----
exit $EXITCODE
