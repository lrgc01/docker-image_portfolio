#!/bin/bash

Usage() {
        echo "Build image or make env to build"
	echo "Usage: $0"
        echo "	-p (prepare env (Dockerfile,etc))"
        echo "	-c (clean env (Dockerfile,etc))"
        echo "	-f <filename> (use alternate name for Dockerfile)"
        echo "	-m - run manifest ONLY"
	echo "	-t <img_tag> (tag image as)"
	echo "	-h this help"
	echo "	--force - force build even if it is up to date"
	echo "	-nc - no cache builder"
        echo "	-d (Dry Run - no arg)"
}

EXITCODE=0

_FORCE=0
_CLEAN_ENV=0
_ENV_ONLY=0
_RUN_MANIFEST=0

WORKDIR="`dirname $0`"
cd "$WORKDIR"

if [ `whoami` != "root" ]; then
        export SUDO="sudo"
fi

DOCKERFILE="Dockerfile.tmp"

while [ $# -gt 0 ]
do
   case $1 in
      -[fF]) 
          if [ "$2" != "" ]; then
             DOCKERFILE="$2"
             shift 2
          else
             echo "Expecting file name after -f"
             Usage
             exit 1
          fi
      ;;
      -[tT]) _TAG="$2"
          shift 2
      ;;
      --[pP][rR][eE][pP][aA]*|-[pP]) 
          _ENV_ONLY="1"
	  _CLEAN_ENV="0"
          DOCKERFILE="Dockerfile"
          shift 1
      ;;
      --[mM][aA][nN][iI][fF]*|-[mM]) 
          _RUN_MANIFEST="1"
	  _CLEAN_ENV="1"
          DOCKERFILE="Dockerfile"
          shift 1
      ;;
      --[cC][lL][eE][aA][nN]|-[cC]) 
          _ENV_ONLY="1"
	  _CLEAN_ENV="1"
          DOCKERFILE="Dockerfile"
          shift 1
      ;;
      --[fF][oO][rR][cC][eE]) 
          _ENV_ONLY="0"
	  _CLEAN_ENV="1"
          DOCKERFILE="Dockerfile"
	  _FORCE="1"
          shift 1
      ;;
      -[nN][cC]) NOCACHE="--no-cache"
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

##############
# ENVIRONMENT
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

_TAG=${_TAG:-"$DIRBASEDTAG"}

# Comes from local.rc definition
if [ ! -z "$_DOCKERBODY" ]; then
   echo "$_DOCKERBODY" > $DOCKERFILE
fi
if [ ! -z "$_STARTBODY" ]; then
   echo "$_STARTBODY" > $STARTFILE
   chmod 755 $STARTFILE
fi
##############

##############
# Build, clean, manifest, etc
#
# Skip if build env only or cleaning only or manifest only
if [ "$_FORCE" -eq 1 -o "$_RUN_MANIFEST" -ne 1 -a "$_CLEAN_ENV" -ne 1 -a "$_ENV_ONLY" -ne 1 ]; then
   PULLIMG=$(grep -e "^FROM " $DOCKERFILE | sed -e 's/FROM //' -e 's/ AS .*//' | head -1)
   UPTODATE=$($DRYRUN $SUDO docker pull -q $PULLIMG )
   
   NEWID=$(CheckImgDependency -l $LASTIDFILE -f $DOCKERFILE $_MINUSD)
   DIFFLASTID=$?
   
   _CLEAN_ENV=1

   if [ "$DIFFLASTID" -eq 0 -a "$_FORCE" -ne 1 ]; then
           echo "No need to update container chain"
           EXITCODE=111
   else
      # Now build the image using docker build only if root is running
   	 $DRYRUN $SUDO docker build $NOCACHE -t ${FOLDER}${_TAG}:${ARCH} -f ${DOCKERFILE} .
   	 if [ $? -eq 0 ]; then
   	    if [ ! -z "$DRYRUN" ]; then
               echo "Would write NEWID according to: $NEWID"
   	    else
           	echo $NEWID | $SUDO tee $LASTIDFILE
   	    fi
            [ ! -z "$(echo $(basename `pwd`) | grep -e '^[0-9][0-9][0-9].*')" ] && _RUN_MANIFEST=1
   	 fi
   fi
fi

if [ "$_RUN_MANIFEST" = "1" ]; then
        $DRYRUN $SUDO docker push ${FOLDER}${_TAG}:${ARCH}
        $DRYRUN $SUDO docker manifest rm ${FOLDER}${_TAG}:latest 
        $DRYRUN $SUDO docker manifest create ${FOLDER}${_TAG}:latest --amend ${FOLDER}${_TAG}:arm64 --amend ${FOLDER}${_TAG}:amd64 --amend ${FOLDER}${_TAG}:armhf
        $DRYRUN $SUDO docker manifest push ${FOLDER}${_TAG}:latest 
fi

# Cleaning
if [ "$_CLEAN_ENV" = "1" ];then
	$DRYRUN $SUDO rm -fr ${OPTDIR} ${DOCKERFILE} Dockerfile.tmp Dockerfile.inc ${TOCLEAN} "$USERDIR_" usr var etc $STARTFILE
	$DRYRUN $SUDO docker image prune -f
fi
exit $EXITCODE
##############
