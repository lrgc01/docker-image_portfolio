#!/bin/sh

WORKDIR="`dirname $0`"
cd "$WORKDIR"

SOURCE_URL=http://httpredir.debian.org/debian

# Change to your needs. It's just an easy way to push it up to docker.com repository.
DOCKER_USER="lrgc01"

DATE_STAMP=$(date +%Y%m%d%H%M)

# Variant is optional
# Min system (man debootstrap)
VARIANT="minbase"

if [ "$VARIANT" != "" ]; then
   VARIANT_OPT="--variant=$VARIANT"
fi

# Mandatory:
# stretch, wheezy, stable, etc
DISTRIB=stable

# You can pass DESTDIR via command argument
DEST_DIR=${1:-"./${VARIANT:-base}_${DISTRIB}-${DATE_STAMP}"}

# Not necessary in most systems (no app will handle network admin for example - it's up to the dockerd daemon)
EXCLUDE_OPT="--exclude=bsdutils,less,manpages,manpages-dev,ifupdown,iproute2,iptables,iputils-ping,isc-dhcp-client,e2fsprogs,dmidecode,ucf,vim-tiny"
# Some others might be included
#INCLUDE_OPT="--include=openssh-server"

# Create image (will take some time... go get a coffee)
debootstrap $VARIANT_OPT $EXCLUDE_OPT $INCLUDE_OPT $DISTRIB $DEST_DIR $SOURCE_URL

# clean after debootstrap process (dpkg / apt)
echo 
echo "Cleaning packages from new image."
echo

# Necessary mount to chroot
mount proc ${DEST_DIR}/proc -t proc
mount sysfs ${DEST_DIR}/sys -t sysfs

# Clean apt stuffs using apt inside rootdir
chroot ${DEST_DIR} apt clean
# Wipe out the repo list archive(s) (about 38MB that will always be updated)
rm -f ${DEST_DIR}/var/lib/apt/lists/httpredir.debian.org*
mkdir ${DEST_DIR}/run/sshd

umount ${DEST_DIR}/sys
umount ${DEST_DIR}/proc


# New name for docker image
echo "Do you want to proceed with docker image import with name $DOCKER_USER/${VARIANT}_${DISTRIB} ?"

read resp
echo

case "$resp" in

  "y"|"Y"|[Yy][Ee][Ss]) 
     echo "Ok. Let's do it."
     tar -C $DEST_DIR -c . | docker import --message "New base system from debootstrap variant $VARIANT" - $DOCKER_USER/${VARIANT}_${DISTRIB}:${DATE_STAMP}
     if [ "$?" -eq 0 ] ; then
        echo "---"
        echo "Now you can wipe out the $DEST_DIR source directory."
        echo "---"
        echo "Listing docker images:"
        echo "---"
     fi
     # list images
     docker images
  ;;

  *) 
     echo "Ok. You may copy and run the corresponding command below just in case:"
     echo "tar -C $DEST_DIR -c . | docker import --message \"New base system from debootstrap variant $VARIANT\" - $DOCKER_USER/${VARIANT}_${DISTRIB}:${DATE_STAMP}"
  ;;

esac

