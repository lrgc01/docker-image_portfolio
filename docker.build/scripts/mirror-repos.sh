#!/bin/sh

Usage() {
        echo "Mirror from origin repo to destination repo"
        echo "
  Usage: $0 
   -o <origin repository prefix>
   -t <target/destination repository prefix>
   -l <build list> (space separated and quoted)
   -s <skip list> (space separated and quoted)
   -d (Dry Run - no arg)
"
}

SCRIPTDIR=$(dirname $0)
BASEDIR="$SCRIPTDIR/.."
SKIPLIST="_none_"

cd "$SCRIPTDIR"

# The generic and then local definition
for RCFILE in "../scripts/generic.rc"
do
        if [ -f "$RCFILE" ]; then
                . "$RCFILE" 
        else
                echo $RCFILE not found 
                exit 2
        fi
done

while [ $# -gt 0 ]
do
   case $1 in
      -[oO]) ORIGIN="$2"
          shift 2
      ;;
      -[tT]) TARGET="$2"
          shift 2
      ;;
      -[lL]) BUILDLIST="$2"
          shift 2
      ;;
      -[sS]) SKIPLIST="$2"
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

if [ $(whoami) != "root" ]; then
	_SUDO="sudo"
fi

#BUILDLIST=${BUILDLIST:-"ssh-stable_slim net-stable_slim isc-dhcp-server dns-bind9 nginx mariadb apache2 samba git nvm node php python3-pip python3-dev python3-pytest gplusplus openjre openjdk jenkins"}
#( cd "$BASEDIR" && _DIRBUILDLIST="$(/bin/ls -d [0-9][0-9][-0-9]*)" ; echo $_DIRBUILDLIST)
cd "$BASEDIR" && _DIRBUILDLIST="$(/bin/ls -d [0-9][0-9][-0-9]*)" && cd -
BUILDLIST=${BUILDLIST:-"$(echo $_DIRBUILDLIST)"}

for bld in $BUILDLIST
do
  _skip="$(echo $SKIPLIST | grep -w $bld)"
  if [ -z "$_skip" ] ; then
    echo "----------------------------------------------"
    echo "   -----   Mirroring $bld   ------  "
    echo "----------------------------------------------"
    ( cd $bld
    CURDIR=$(pwd)
    _TAG="$(basename $CURDIR | sed -e 's/[0-9][0-9][0-9]-//')"
       $DRYRUN $_SUDO docker pull ${ORIGIN}${_TAG}:${ARCH} && \
       $DRYRUN $_SUDO docker image tag ${ORIGIN}${_TAG}:${ARCH} ${TARGET}${_TAG}:${ARCH} && \
       $DRYRUN $_SUDO docker push ${TARGET}${_TAG}:${ARCH} && \
       $DRYRUN $_SUDO docker manifest rm ${TARGET}${_TAG}:latest 
       $DRYRUN $_SUDO docker manifest create ${TARGET}${_TAG}:latest --amend ${TARGET}${_TAG}:arm64 --amend ${TARGET}${_TAG}:amd64 --amend ${TARGET}${_TAG}:armhf && \
       $DRYRUN $_SUDO docker manifest push ${TARGET}${_TAG}:latest 
    )
  else
    echo "Skipping $bld"
  fi
done

# another run to clean downloaded origin images
for bld in $BUILDLIST
do
  _skip="$(echo $SKIPLIST | grep -w $bld)"
  if [ -z "$_skip" ] ; then
    echo "----------------------------------------------"
    echo "   -----   Cleaning for $bld   ------  "
    echo "----------------------------------------------"
    ( cd $bld
       CURDIR=$(pwd)
       _TAG="$(basename $CURDIR | sed -e 's/[0-9][0-9][0-9]-//')"
       $DRYRUN $_SUDO docker image rm ${ORIGIN}${_TAG}:${ARCH} ${TARGET}${_TAG}:${ARCH}
    )
  fi
done

$DRYRUN $_SUDO docker image prune -f
