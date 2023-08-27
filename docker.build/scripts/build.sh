#!/bin/sh

# docker inspect --format {{.Id}} $docker_image_name

Usage() {
        echo "Basic image build"
        echo "Usage: $0 -d (Dry Run - no arg)"
}

EXITCODE=0

WORKDIR="$(dirname $0)"
cd "$WORKDIR"

RCFILE="../scripts/generic.rc"
[ -f "$RCFILE" ] && . $RCFILE

# Overwrite DOCKERFILE with special Dockerfile.build which is permanent, i.e. no generated, but static
DOCKERFILE="Dockerfile.build"

#CURDIR=$(pwd)
#_TAG=$(basename $CURDIR)

TAGNAME="${BASE_FOLDER%/}/$_TAG"

if [ `whoami` != "root" ]; then
	SUDO="sudo"
fi

while [ $# -gt 0 ]
do
   case $1 in
      -[fF]) DOCKERFILE="$2"
          shift 2
      ;;
      -[tT]) TAGNAME="$2"
          shift 2
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

PULLIMG=$(grep -e "^FROM " $DOCKERFILE | sed -e 's/FROM //')
UPTODATE=$($DRYRUN $SUDO docker pull $PULLIMG | grep -e 'up to date')

NEWID=$(CheckImgDependency -l $LASTIDFILE -f $DOCKERFILE $_MINUSD)
DIFFLASTID=$?

if [ ! -z "$UPTODATE" -a "$DIFFLASTID" -eq 0 ]; then
	echo "No need to update container chain"
	EXITCODE=111
else
	$DRYRUN $SUDO docker build -f $DOCKERFILE -t $TAGNAME:${ARCH} .
	if [ $? -eq 0 ]; then
	   $DRYRUN $SUDO docker push $TAGNAME:${ARCH}
	   $DRYRUN echo $NEWID > $LASTIDFILE
           $DRYRUN $SUDO docker manifest rm ${TAGNAME}:latest
	   $DRYRUN $SUDO docker manifest create ${TAGNAME}:latest --amend ${TAGNAME}:amd64 --amend ${TAGNAME}:arm64
           $DRYRUN $SUDO docker manifest push ${TAGNAME}:latest
	   $DRYRUN $SUDO docker image prune -f
	fi
fi

exit $EXITCODE
