#!/bin/bash

# Some environment variables that may be passed to the container
# Any file/script can be uploaded inside a volume using the Docker Host
START_SH=${DOCKER_START_SH:-"qbittorrent.sh"}
WORKDIR=${DOCKER_WORKDIR:-"/data"}

# Start of the container main purpose app
if [ -d "$WORKDIR" ]; then
   cd "$WORKDIR"
fi

# If there is a application script, run it, otherwise run sshd below
if [ -f "$START_SH" ]; then
   bash "$START_SH"
else
   if [ -d "/data" ];  then
      # workaround to get my ip
      grep -w $(hostname) /etc/hosts | awk '{print $1}' > "/data/host.ip"
   fi
   # -D to run the daemon in foreground
   /usr/sbin/sshd -D
fi

