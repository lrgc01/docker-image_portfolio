#!/bin/sh

Usage() {
        echo "Make periodic build across all container definitions"
        echo "
  Usage: $0 
   -p prepare env (Dockerfile,etc) 
   -f force build 
   -c clean
   -l <build list> (space separated and quoted)
   -s <skip list> (space separated and quoted)
   -nc (do not use builder cache)
   -d (Dry Run - no arg)
"
}

SCRIPTDIR=$(dirname $0)
BASEDIR="$SCRIPTDIR/.."
SKIPLIST="_none_"

while [ $# -gt 0 ]
do
   case $1 in
      -[pP]) PREPARE="-p"
          shift 1
      ;;
      -[fF]) FORCE="--force"
          shift 1
      ;;
      -[cC]) CLEAN="-c"
          shift 1
      ;;
      -[lL]) BUILDLIST="$2"
          shift 2
      ;;
      -[sS]) SKIPLIST="$2"
          shift 2
      ;;
      -[nN][cC]) NOCACHE="-nc"
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
	_SUDO="sudo"
fi

# Order is VERY important here
#BUILDLIST=${BUILDLIST:-"ssh-stable_slim net-stable_slim isc-dhcp-server dns-bind9 nginx mariadb apache2 samba git nvm node php python3-pip python3-dev python3-pytest gplusplus openjre openjdk jenkins"}
#( cd "$BASEDIR" && _DIRBUILDLIST="$(/bin/ls -d [0-9][0-9][-0-9]*)" ; echo $_DIRBUILDLIST)
cd "$BASEDIR" && _DIRBUILDLIST="$(/bin/ls -d [0-9][0-9][-0-9]*)" && cd -
BUILDLIST=${BUILDLIST:-"$(echo $_DIRBUILDLIST)"}

for bld in $BUILDLIST
do
  _skip="$(echo $SKIPLIST | grep -w $bld)"
  if [ -z "$_skip" ] ; then
    echo "----------------------------------------------"
    echo "   -----   Running in $BASEDIR/$bld   ------  "
    echo "----------------------------------------------"
    ( cd $BASEDIR/$bld 
      [ -f ./create.sh ] && $_SUDO ./create.sh $CLEAN $_MINUSD $PREPARE $FORCE $NOCACHE
    )
    #if [ $? -ne 0 -a "$FORCE" != "-f" ]; then
    #	break
    #fi
  else
    echo "Skipping $bld"
  fi
done

#$DRYRUN $_SUDO docker image prune -f
