#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stable_slim

LABEL Comment="HAproxy web loadbalancer over ssh-stretch_slim image"

RUN apt-get update && \
    apt-get install -q -y haproxy --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start.d 

COPY haproxy.start haproxy.cfg.tmpl haproxy_cfg.start.sh /start.d/

# Obvious Web ports and others
EXPOSE 80
EXPOSE 443
EXPOSE 8000
EXPOSE 8080
EXPOSE 8443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/haproxy", "/var/log/haproxy" ]

CMD ["sh","/start.d/haproxy.start"]
