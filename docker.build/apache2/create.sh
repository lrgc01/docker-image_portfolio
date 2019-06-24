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

COMMENT="Apache2 web server over openssh-server image"
IMGNAME="apache2-stretch_slim"

# Not used, just in case ...
UID_=${APACHE2_UID:-102}
GID_=${APACHE2_GID:-103}
USR_=${APACHE2_USR:-pyuser}
GRP_=${APACHE2_GRP:-pygrp}
# This is globally used
USERDIR_=${APACHE2_HOMEDIR:-var/lib/apache2}
USERDIR_=${USERDIR_#/}
START_DIR="start"

START_CMD=${APACHE_START_CMD:-"apache2.start"}
IPFILE=${APACHE_IPFILE:-"apache2.host"}

# 
# ---- Start command ----
#    ... with workaround to get IP 
#

cat > $START_CMD << EOF
#!/bin/bash

CFG_DIR="/etc/apache2"
MOD_AV_DIR="mods-available"
MOD_EN_DIR="mods-enabled"

# Basic initial configuration based on some env variables
#
# ----------------
# APACHE2_MOD_LIST - module name (no suffix) space separated
# ex.: APACHE2_MOD_LIST="mod_proxy mod_proxy_uwsgi"
#
if [ ! -z "\$APACHE2_MOD_LIST" ] ; then 
     cd \$CFG_DIR/\$MOD_EN_DIR
     for mod_ in \$APACHE2_MOD_LIST
     do
        [ -f "../\$MOD_AV_DIR/\${mod_}.load" ] && ln -fs "../\$MOD_AV_DIR/\${mod_}.load" .
        [ -f "../\$MOD_AV_DIR/\${mod_}.conf" ] && ln -fs "../\$MOD_AV_DIR/\${mod_}.conf" .
     done
fi
# ----------------

cd /

apachectl start

# For testing purposes and to avoid using another daemon control, 
# just call sshd to hold the terminal then start sshd without 
# detach (but change off to on in apache2 call)
/usr/sbin/sshd -D

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="$COMMENT"

RUN apt-get update && \\
    apt-get install -y apache2 libapache2-mod-fcgid libapache2-mod-proxy-uwsgi --no-install-recommends && \\
    apt-get clean && \\
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \\
    rm -fr /var/lib/apt/lists/* && \\
    rm -fr /usr/share/man/man* && \\
    mkdir -p /run/php /$START_DIR 

COPY $START_CMD /$START_DIR/

# Obvious Web ports
EXPOSE 80
EXPOSE 443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/apache2", "/var/log/apache2", "/var/www/html"]

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

