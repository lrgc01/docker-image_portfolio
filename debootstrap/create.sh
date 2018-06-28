#!/bin/sh

SOURCE_URL=http://httpredir.debian.org/debian

DOCKER_USER="lrgc01"

# Min system (man debootstrap)
VARIANT="minbase"

if [ "$VARIANT" != "" ]; then
   VARIANT_ARG="--variant=$VARIANT"
fi

# stretch, wheezy, stable, etc
DISTRIB=stable

if [ "$1" = "" ]; then
  DEST_DIR=./build/${DISTRIB}-`date +%m%d%H%M` 
else
  DEST_DIR="$1"
fi

# Not used yet
EXCLUDE="--exclude=openssh-client,ifupdown,iproute2,iptables,iputils-ping,isc-dhcp-client,e2fsprogs,dmidecode,ucf,vim-tiny"

debootstrap $VARIANT_ARG $DISTRIB $DEST_DIR $SOURCE_URL

# New name for docker image
echo "Wanna proceed with docker image import with name $DOCKER_USER/$VARIANT_$DISTRIB ?"

read resp

case "$resp" in

  "y"|"Y") 
     echo "Ok. Let's do it."
     tar -C $DEST_DIR -c . | docker import --message \"New base system from debootstrap variant $VARIANT\" - $DOCKER_USER/${VARIANT}_${DISTRIB}
     # list images
     docker images
  ;;

  *) 
     echo "Ok. You may copy and run the corresponding command below just in case:"
     echo "tar -C $DEST_DIR -c . | docker import --message \"New base system from debootstrap variant $VARIANT\" - $DOCKER_USER/${VARIANT}_${DISTRIB}"
  ;;

esac
