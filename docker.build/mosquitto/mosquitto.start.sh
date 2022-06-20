#!/bin/sh

ETCD="/etc/mosquitto"
CERTDIR="$ETCD/certs"
CACERTDIR="$ETCD/ca_certificates"
PASSWDFILE="$ETCD/authorization_file" # use mosquitto_passwd to create one
LISTENERCONF="$ETCD/conf.d/listener.conf"

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
fi

chown -R mosquitto /etc/mosquitto

# No -d = no daemon
mosquitto -c /etc/mosquitto/mosquitto.conf
