#!/bin/bash

# workaround to get my ip
grep -w $(hostname) /etc/hosts | awk '{print $1}' > "/start/host.ip"

/usr/sbin/sshd -D

