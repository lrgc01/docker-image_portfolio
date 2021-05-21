#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stable_slim

LABEL Comment="ISC DHCP server"

RUN apt-get update && \
    apt-get install -y isc-dhcp-server --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start.d 

COPY dhcp.bootstrap   /start.d/

# Standard dhcp ports
EXPOSE 67
EXPOSE 68

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["//etc/dhcp", "/var/log/dhcp" ]

CMD ["sh","/start.d/dhcp.bootstrap"]
