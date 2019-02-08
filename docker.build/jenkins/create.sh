#!/bin/bash

WORKDIR="`dirname $0`"
cd "$WORKDIR"

# Folder is optional - end with a slash
FOLDER="lrgc01/"
IMGNAME="jenkins"
# Versioning in order to keep a copy if running more than once
# Note the ":" in the formated output
# May change for own needs
BUILD_VER=$(date +:%Y%m%d%H%M)

# Now build the image using docker build
docker build -t ${FOLDER}${IMGNAME}${BUILD_VER} .

