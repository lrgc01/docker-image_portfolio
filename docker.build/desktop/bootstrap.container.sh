#!/bin/bash
rm -f /run/dbus/pid  /var/run/xrdp/xrdp-sesman.pid /var/run/xrdp/xrdp.pid /run/avahi-daemon/pid
syslogd
dbus-daemon --system
/usr/sbin/avahi-daemon -s -D
#/usr/libexec/polkitd --no-debug
/usr/lib/polkit-1/polkitd --no-debug &
lightdm &
xrdp-sesman
xrdp

