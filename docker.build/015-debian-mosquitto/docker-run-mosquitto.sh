#!/bin/sh

NAME=${NAME:-"mosquitto"}
PORT=${PORT:-"1883"}
SSLPORT=${SSLPORT:-"8883"}
# Example to use bridge
#BRIDGEADDR="mqtt.internal.domain.com:1884"

CERTDIR=${CERTDIR:-"/home/luiz/start.d/certs"}
LOCALSTARTSH=${LOCALSTARTSH:-"/home/luiz/start.d/mosquitto.start.sh"}
DOCKERCERTDIR="/etc/mosquitto/certs"
DOCKERCACERTPATH="/etc/mosquitto/ca_certificates"

# To new certs:
CASUBJ=${CASUBJ:-"/C=BR/ST=RJ/L=Rio\ de\ Janeiro/O=Living/OU=CA-cert/CN=sddc.living-consultoria.com.br"}
CERTSUBJ=${CERTSUBJ:-"/C=BR/ST=RJ/L=Rio\ de\ Janeiro/O=Aeroporto\ Galeao/OU=IoT-GIG/CN=mqtt.sddc.living-consultoria.com.br"}
#CASUBJ='/C=BR/ST=RJ/L=Rio de Janeiro/O=Living/OU=CA-cert/CN=armubuntu2'
#CERTSUBJ='/C=BR/ST=RJ/L=Rio de Janeiro/O=Aeroporto Galeao/OU=IoT-GIG/CN=oci-armubuntu2'

ARCH=`dpkg --print-architecture`

USE_BRIDGE="no"
if [ ! -z $BRIDGEADDR ]; then
    USE_BRIDGE="yes"
    MOSQUITTO_BRIDGE="-e DOCKER_BRIDGEADDR=$BRIDGEADDR"
fi

if [ `whoami` != "root" ]; then
    SUDO="sudo"
fi

$SUDO docker create \
  --name=$NAME \
  --restart unless-stopped \
  -e DOCKER_START_SH="/start.d/mosquitto.start.sh" \
  -e DOCKER_USE_BRIDGE="$USE_BRIDGE" \
  $MOSQUITTO_BRIDGE \
  -v etc_$NAME:/etc/mosquitto \
  -v log_$NAME:/var/log/mosquitto \
  -v lib_$NAME:/var/lib/mosquitto \
  --publish 0.0.0.0:$SSLPORT:8883 \
  --publish 0.0.0.0:$PORT:1883 \
  lrgc01/mosquitto:${ARCH}

if [ ! -d "$CERTDIR" ] ; then
   mkdir -p "$CERTDIR"
   (  
      cd "$CERTDIR"
      openssl genrsa -out server.key 2048
      openssl genrsa -out ca.key 2048
      openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "$CASUBJ"
      openssl req -new -out server.csr -key server.key -subj "$CERTSUBJ"
      openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
   )
fi
(  
   cd "$CERTDIR"
   # Some copies before starting - if needed
   for file in ca.crt ca.key ca.srl 
   do
      $SUDO docker cp $file $NAME:$DOCKERCACERTPATH
   done
   for file in server.crt server.csr server.key
   do
      $SUDO docker cp $file $NAME:$DOCKERCERTDIR
   done
)

$SUDO docker cp "$LOCALSTARTSH" $NAME:/start.d
$SUDO docker start $NAME
