#!/bin/sh

if [ ! -d "/run/mosquitto" ] ; then
   mkdir -p /run/mosquitto 
fi
chown mosquitto /run/mosquitto

# No -d = no daemon
mosquitto -c /etc/mosquitto/mosquitto.conf
