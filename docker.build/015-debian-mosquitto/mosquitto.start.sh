#!/bin/sh

ETCD="/etc/mosquitto"
CERTDIR="$ETCD/certs"
CACERTDIR="$ETCD/ca_certificates"
PASSWDFILE="$ETCD/authorization_file" # use mosquitto_passwd to create one
LISTENERCONF="$ETCD/conf.d/00-listener.conf"
BRIDGECONF="$ETCD/conf.d/10-bridge.conf"
USE_BRIDGE=${DOCKER_USE_BRIDGE:-"no"}
BRIDGECONN=${DOCKER_BRIDGECONN:-"bridge-01"}
BRIDGEADDR=${DOCKER_BRIDGEADDR:-"172.17.0.3:1883"}
BRIDGEUSER=${DOCKER_BRIDGEUSER:-"bridge"}
BRIDGEPASS=${DOCKER_BRIDGEPASS:-'P!zzBridge'}

if [ ! -d "/run/mosquitto" ] ; then
   mkdir -p /run/mosquitto 
fi
chown mosquitto /run/mosquitto

if [ ! -f "$LISTENERCONF" ] ; then
   cat > $LISTENERCONF << EOF
# MQTT, no encrypt
listener 1883
allow_anonymous false
set_tcp_nodelay true

# MQTT, encrypt
listener 8883
allow_anonymous false
set_tcp_nodelay true
require_certificate false
cafile $CACERTDIR/ca.crt
certfile $CERTDIR/server.crt
keyfile $CERTDIR/server.key
password_file /etc/mosquitto/authorization_file
EOF
fi

if [ ! -f "$PASSWDFILE" ]; then
   touch $PASSWDFILE
   chown mosquitto:mosquitto $PASSWDFILE
   # Start with the bridge user for later use
   mosquitto_passwd -b $PASSWDFILE $BRIDGEUSER "$BRIDGEPASS"
fi

case "$USE_BRIDGE" in
    [yY][eE][sS])
        if [ ! -f "$BRIDGECONF" ]; then
        cat > $BRIDGECONF << EOF
connection $BRIDGECONN
address $BRIDGEADDR
remote_username $BRIDGEUSER
remote_password $BRIDGEPASS
local_cleansession true
topic # both 1 "" remote/
EOF
        fi
	;;
esac

chown -R mosquitto /etc/mosquitto

# No -d = no daemon
mosquitto -c /etc/mosquitto/mosquitto.conf
