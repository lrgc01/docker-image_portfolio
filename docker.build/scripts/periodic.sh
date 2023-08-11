#!/bin/sh

Usage() {
        echo "Make periodic build across all container definitions"
        echo "Usage: $0 -p <prepare env (Dockerfile,etc)> -f <force build> -d (Dry Run - no arg)"
}

SCRIPTDIR=$(dirname $0)
BASEDIR="$SCRIPTDIR/.."

while [ $# -gt 0 ]
do
   case $1 in
      -[fF]) FORCE="-f"
          shift 1
      ;;
      -[pP]) PREPARE="-p"
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

if [ $(whoami) != "root" ]; then
	SUDO="sudo"
fi

# Order is VERY important here
BUILDLIST="ssh-stable_slim net-stable_slim dns-bind9 python3-pip nginx mariadb apache2 openjre openjdk jenkins"

for bld in $BUILDLIST
do
	echo "Running in $BASEDIR/$bld"
	( cd $BASEDIR/$bld 
          [ -f ./build.sh ] && $DRYRUN ./build.sh 
          [ -f ./create.sh ] && $DRYRUN ./create.sh $PREPARE
  	)
	#if [ $? -ne 0 -a "$FORCE" != "-f" ]; then
	#	break
	#fi
done

$DRYRUN $SUDO docker builder prune -f
