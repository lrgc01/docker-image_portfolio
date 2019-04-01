#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="nginx web server over openssh-server image"

COPY nginx.start /

RUN apt-get clean && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir /run/php && \
    chmod 755 /nginx.start

# Obvious Web ports
EXPOSE 80
EXPOSE 443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/nginx", "/var/log/nginx", "/var/www/html"]

CMD ["/nginx.start"]
