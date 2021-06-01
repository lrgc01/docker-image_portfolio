#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/net-stable_slim

LABEL Comment="bind9 DNS server"

RUN apt-get update && \
    apt-get install -y bind9 --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start.d 

COPY bind.bootstrap   /start.d/

# Obvious Web ports and others
EXPOSE 53

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["//etc/bind", "/var/log/bind" ]

CMD ["sh","/start.d/bind.bootstrap"]
