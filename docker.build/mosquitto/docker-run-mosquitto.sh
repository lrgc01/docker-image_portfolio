#!/bin/sh

ARCH=`dpkg --print-architecture`
NAME="mosquitto"
DOCKERCERTDIR="/etc/mosquitto/certs"
DOCKERCACERTPATH="/etc/mosquitto/ca_certificates"
CERTDIR="/home/luiz/start.d/certs"
# To new certs:
CASUBJ="/C=BR/ST=RJ/L=Rio\ de\ Janeiro/O=Living/OU=CA-cert/CN=sddc.living-consultoria.com.br"
CERTSUBJ="/C=BR/ST=RJ/L=Rio\ de\ Janeiro/O=Aeroporto\ Galeao/OU=IoT-GIG/CN=mqtt.sddc.living-consultoria.com.br"
#CASUBJ='/C=BR/ST=RJ/L=Rio de Janeiro/O=Living/OU=CA-cert/CN=armubuntu2'
#CERTSUBJ='/C=BR/ST=RJ/L=Rio de Janeiro/O=Aeroporto Galeao/OU=IoT-GIG/CN=oci-armubuntu2'


if [ `whoami` != "root" ]; then
	SUDO="sudo"
fi

$SUDO docker create \
  --name=$NAME \
  --restart unless-stopped \
  -e DOCKER_START_SH=/start/mosquitto.start.sh \
  -v etc_mosquitto:/etc/mosquitto \
  -v log_mosquitto:/var/log/mosquitto \
  -v lib_mosquitto:/var/lib/mosquitto \
  --publish 0.0.0.0:8883:8883 \
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

$SUDO docker cp "mosquitto.start.sh" $NAME:/start
$SUDO docker start $NAME
