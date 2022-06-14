#!/bin/sh

ETCD="/etc/mosquitto"
CERTDIR="$ETCD/certs"
PASSWDFILE="$ETCD/authorization_file" # use mosquitto_passwd to create one
SOCKETCONF="$ETCD/conf.d/socket_domain.conf"
SSLCONF="$ETCD/conf.d/ssl.conf"
AUTHCONF="$ETCD/conf.d/auth.conf"

if [ ! -d "/run/mosquitto" ] ; then
   mkdir -p /run/mosquitto 
fi
chown mosquitto /run/mosquitto

if [ ! -f "$SOCKETCONF" ] ; then
   echo "socket_domain ipv4" > $SOCKETCONF
   echo "listener 8883" >> $SOCKETCONF # 8883 means use CA/CERTS provided by OS
fi

if [ ! -f "$SSLCONF" ] ; then
   echo "require_certificate false" >> $SSLCONF
fi
if [ ! -f "$AUTHCONF" ] ; then
   echo "password_file /etc/mosquitto/authorization_file" > $AUTHCONF
fi

chown -R mosquitto /etc/mosquitto

# No -d = no daemon
mosquitto -c /etc/mosquitto/mosquitto.conf
