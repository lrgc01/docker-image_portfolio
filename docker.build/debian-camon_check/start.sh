#!/bin/bash

# workaround to get my ip
#grep -w $(hostname) /etc/hosts | awk '{print $1}' > "/var/lib/jenkins/ssh.host"

# start sshd without detach 
#/usr/sbin/sshd -D
/usr/sbin/sshd

CamON-check.sh -v
