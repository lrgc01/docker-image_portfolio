#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# The generic definition
[ -f ../generic.rc ] && . ../generic.rc

# Folder is optional - end with a slash
FOLDER=${BASE_FOLDER:-"lrgc01/"}
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=${GLOBAL_TAG_VER:-$(date +:%Y%m%d%H%M)}

# Optionaly this script can prepare the docker-build environment
if [ "$#" -gt 0 ]; then
   case "$1" in
      env|prepare|Dockerfile)
	BUILD_ENV="1"
        DOCKERFILE="Dockerfile"
   ;;
   esac
else
   DOCKERFILE="Dockerfile.tmp"
fi

COMMENT="ISC DHCP server"
IMGNAME="isc-dhcp-server"
FROM="lrgc01/net-stable_slim"

# Not used, just in case ...
UID_=${DHCP_UID:-67}
GID_=${DHCP_GID:-67}
USR_=${DHCP_USR:-dhcp}
GRP_=${DHCP_GRP:-dhcp}
# This is globally used
USERDIR_=${DHCP_HOMEDIR:-/etc/dhcp}
USERDIR_=${USERDIR_#/}

START_CMD=${DHCP_START_CMD:-"dhcp.bootstrap"}
IPFILE=${DHCP_IPFILE:-"dhcp.host"}
START_DIR="start.d"
DHCP_DIR=${DHCP_DIR:-"/etc/dhcp"}
# These two will be used in a base startup run
#START_SCRIPT="bind.start.sh"
#TMPL="bind.cfg.tmpl"

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

# Some environment variables that may be passed to the container
# Any file/script can be uploaded inside a volume using the Docker Host
START_SH=\${DOCKER_START_SH:-"$START_SCRIPT"}
WORKDIR=\${DOCKER_WORKDIR:-"/$START_DIR"}

# Start of the container main purpose app
if [ -d "\$WORKDIR" ]; then
   cd "\$WORKDIR"
fi

# If there is a application script, run it, otherwise run sshd below
if [ -f "\$START_SH" ]; then
   bash "\$START_SH"
else
   if [ -d "/$USERDIR_" ];  then
      # workaround to get my ip
      grep -w \$(hostname) /etc/hosts | awk '{print \$1}' > "/$USERDIR_/$IPFILE"
   fi
   # -f runs in foreground
   /usr/sbin/dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf -f eth0
   # -D to run the daemon in foreground
   /usr/sbin/sshd -D
fi

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROM

LABEL Comment="$COMMENT"

RUN apt-get update && \\
    apt-get install -y isc-dhcp-server --no-install-recommends && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* && \\
    mkdir -p /$START_DIR 

COPY $START_CMD $TMPL $START_SCRIPT /$START_DIR/

# Standard dhcp ports
EXPOSE 67
EXPOSE 68

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/$DHCP_DIR", "/var/log/$USR_" ]

CMD ["sh","/$START_DIR/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
fi

