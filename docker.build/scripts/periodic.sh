#!/bin/sh

SCRIPTDIR=$(dirname $0)
BASEDIR="$SCRIPTDIR/.."

if [ $(whoami) != "root" ]; then
	SUDO="sudo"
fi

# Order is VERY important here
BUILDLIST="ssh-stable_slim net-stable_slim"

for bld in $BUILDLIST
do
	echo "Running in $BASEDIR/$bld"
	( cd $BASEDIR/$bld ; ./build.sh )
	if [ $? -ne 0 ]; then
		break
	fi
done

$SUDO docker builder prune -f
