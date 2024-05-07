#!/bin/bash

DEBUG=${DOCKER_DEBUG:-"0"}
ENVFILE=${DOCKER_ENV_FILE:-"$USERDIR_/env.rc"}

[ "$DEBUG" != "0" ] && set -x

# NVM stuff
#export NVM_DIR="$USERDIR_/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f "$ENVFILE" ] && . "$ENVFILE"

which n8n > /dev/null 2>&1
[ "$?" != "0" ] && npm install n8n -g

n8n start

