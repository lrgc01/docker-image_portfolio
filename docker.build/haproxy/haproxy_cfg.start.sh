#!/bin/sh

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME
TEMPLATE="haproxy.cfg.tmpl"

FE_PORT=${DOCKER_FE_PORT:-"8000"}
BE_PORT=${DOCKER_BE_PORT:-"8000"}
BACKEND_NAME=${DOCKER_BE_NAME:-"BEservers"}

STATS_USER=${DOCKER_STATSUSR:-"admin"}
STATS_PASSWORD=${DOCKER_STATSPW:-"haprx123456"}
STATS_PORT=${DOCKER_STATS_PORT:-"9876"}

NUM_BE_SRV=${DOCKER_NUM_BE_SRV:-"3"}
NETBASE=$DOCKER_NETBASE
# BE_SERVER_LIST

if [ -z $NETBASE ]; then
   NETBASE=$(grep -w `hostname` /etc/hosts| awk '{print $1}'|head -1|sed -e 's/\([0-9]*\.\)\([0-9]*\.\)\([0-9]*\.\)[0-9]*/\1\2\3/')
fi

# Start from host number 3 in the same network - haproxy docker container must be created first
COUNT=1
NUM=2
while [ $COUNT -le $NUM_BE_SRV ] 
do
	BE_SERVER_LIST="${BE_SERVER_LIST}    server srv$NUM ${NETBASE}${NUM}:$BE_PORT cookie srv$NUM check\n"
	COUNT=$(expr $COUNT + 1)
	NUM=$(expr $NUM + 1)
done
sed -e 's/__FE_PORT__/'"$FE_PORT"'/' \
	-e 's/__BE_PORT__/'"$BE_PORT"'/' \
	-e 's/__BACKEND_NAME__/'"$BACKEND_NAME"'/' \
	-e 's/__STATS_USER__/'"$STATS_USER"'/' \
	-e 's/__STATS_PASSWORD__/'"$STATS_PASSWORD"'/' \
	-e 's/__STATS_PORT__/'"$STATS_PORT"'/' \
	-e 's/__BE_SERVER_LIST__/'"$BE_SERVER_LIST"'/' $TEMPLATE > /etc/haproxy/haproxy.cfg

haproxy -V -db -f /etc/haproxy/haproxy.cfg
