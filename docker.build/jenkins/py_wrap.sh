#!/bin/sh

# Dynamic
#PYHOST="`grep -w $(hostname) /etc/hosts | awk '{print $1}'`"
if [ -f ~/python.host ]; then
   PYHOST=$(cat ~/python.host)
else
   echo "Could not determine python server IP. No ~/python.host file."
   exit 1
fi

CWD="`pwd`"
COMMAND=`basename $0`

if [ "$COMMAND" = "python" ] ; then
   ssh -o StrictHostKeyChecking=no $PYHOST "(cd \"$CWD\" ; python3 "$@" )"
else
   ssh -o StrictHostKeyChecking=no $PYHOST "(cd \"$CWD\" ; $COMMAND "$@" )"
fi

