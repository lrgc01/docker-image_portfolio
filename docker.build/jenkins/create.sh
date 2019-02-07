#!/bin/bash

WORKDIR="`dirname $0`"

cd "$WORKDIR"

BUILD_VER=$(date +%Y%m%d%H%M)

# Now build the image using docker build
docker build -t lrgc01/jenkins:${BUILD_VER} .

