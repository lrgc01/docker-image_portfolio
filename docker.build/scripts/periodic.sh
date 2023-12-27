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
	_SUDO="sudo"
fi

# Order is VERY important here
BUILDLIST=${BUILDLIST:-"ssh-stable_slim net-stable_slim isc-dhcp-server dns-bind9 nginx mariadb apache2 samba git nvm node php python3-pip python3-dev python3-pytest openjre openjdk jenkins"}
# The list is getting to long for smaller machines - try divide in crontab
#BUILDLIST=${BUILDLIST:-"ssh-stable_slim net-stable_slim isc-dhcp-server dns-bind9 nginx mariadb apache2 samba git nvm node php python3-pip python3-dev python3-pytest openjre openjdk jenkins debian-nox11 kali-ssh kali-net kali-git kali-nox11"}

for bld in $BUILDLIST
do
	echo "Running in $BASEDIR/$bld"
	( cd $BASEDIR/$bld 
          [ -f ./build.sh ] && $DRYRUN $_SUDO ./build.sh 
          [ -f ./create.sh ] && $DRYRUN $_SUDO ./create.sh $PREPARE
  	)
	#if [ $? -ne 0 -a "$FORCE" != "-f" ]; then
	#	break
	#fi
done

#$DRYRUN $_SUDO docker image prune -f
