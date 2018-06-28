#!/bin/sh

SOURCE_URL=http://httpredir.debian.org/debian

# Min system (man debootstrap)
VARIANT="--variant=minbase"

# stretch, wheezy, stable, etc
DISTRIB=stable

if [ "$1" = "" ]; then
  DEST_DIR=./build/${DISTRIB}-`date +%m%d%H%M` 
else
  DEST_DIR="$1"
fi

# Not used yet
EXCLUDE="--exclude=openssh-client,ifupdown,iproute2,iptables,iputils-ping,isc-dhcp-client,e2fsprogs,dmidecode,ucf,vim-tiny"

debootstrap $VARIANT $DISTRIB $DEST_DIR $SOURCE_URL

