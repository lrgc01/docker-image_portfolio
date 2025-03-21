#!/bin/sh
set -e

MYNAME=$(basename $0 .sh)

# Run command with $MYNAME if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- ${MYNAME} "$@"
fi

# NOTE: Only works for "docker run", not "docker exec" which tries to execute anything after the
# running container name and treats dash parameter as a potential command.

exec "$@"
