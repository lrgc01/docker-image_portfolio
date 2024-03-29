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

COMMENT="etcd server over openssh-server image"
IMGNAME="etcd"

ETCD_VER="v3.3.13"
# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
BASE_URL=${GOOGLE_URL}

ETCD_URL="${BASE_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz"

START_CMD=${ETCD_START_CMD:-"etcd.start"}
IPFILE=${ETCD_IPFILE:-"etcd.host"}

# 
# ---- Start command ----
#

cat > $START_CMD << EOF
#!/bin/bash

# Simple start - to do a more complete call rememter to use /usr/local/bin
# A nice idea is to use /etcd-data as a docker volume
# Listen on all IPs - let docker handle binding.
/usr/local/bin/etcd --name s1 \\
	--data-dir /etcd-data \\
	--listen-client-urls http://0.0.0.0:2379 \\
	--advertise-client-urls http://0.0.0.0:2379 \\
	--listen-peer-urls http://0.0.0.0:2380 \\
	--initial-advertise-peer-urls http://0.0.0.0:2380 \\
	--initial-cluster s1=http://0.0.0.0:2380 \\
	--initial-cluster-token tkn \\
	--initial-cluster-state new

EOF
# Seems useless, because when COPY by Dockerfile it looses file mode
chmod 755 $START_CMD

#
# ---- end workaround IP ----

cat > ${DOCKERFILE} << EOF
#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM $FROMIMG

LABEL Comment="$COMMENT"

COPY $START_CMD /

ADD ${ETCD_URL} /tmp/etcd.tgz

RUN mkdir /tmp/etcd.tmp && \\
    tar -xf /tmp/etcd.tgz -C /tmp/etcd.tmp && \\
    find /tmp/etcd.tmp -maxdepth 2 \( -name etcd -o -name etcdctl \) -type f -exec cp -p {} /usr/local/bin \\; && \\
    rm -fr /tmp/etcd.tgz /tmp/etcd.tmp && \\
    chmod 755 /$START_CMD

# Obvious Web ports
EXPOSE 2379
EXPOSE 2380

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etcd-data"]

CMD ["/$START_CMD"]
EOF

# Now build the image using docker build only if root is running
if [ `whoami` = "root" -a "$BUILD_ENV" != "1" ]; then
  docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} -f ${DOCKERFILE} .
  if [ $? -eq 0 ]; then
     docker image tag ${FOLDER}${IMGNAME}${BUILD_VER} ${FOLDER}${IMGNAME}:${ARCH} 
     docker image rm ${FOLDER}${IMGNAME}${BUILD_VER}
  fi
fi

if [ "$DOCKERFILE" != "Dockerfile" ] ; then
   # Cleaning only if Dockerfile.tmp is the current one
   rm -fr ${OPTDIR} ${DOCKERFILE} $START_CMD
fi

