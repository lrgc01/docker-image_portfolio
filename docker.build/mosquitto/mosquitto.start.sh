#!/bin/sh

if [ ! -d "/run/mosquitto" ] ; then
   mkdir -p /run/mosquitto 
fi
chown mosquitto /run/mosquitto
if [ ! -f "/etc/mosquitto/conf.d/socket_domain.conf" ] ; then
   echo "socket_domain ipv4" > /etc/mosquitto/conf.d/socket_domain.conf
fi

# No -d = no daemon
mosquitto -c /etc/mosquitto/mosquitto.conf
