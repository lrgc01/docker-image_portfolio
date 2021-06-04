#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM debian:stable-slim

LABEL Comment="nginx web server over openssh-server image"

RUN apt-get update && \
    apt-get install -q -y nginx && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start 

COPY nginx.start /start/

# Obvious Web ports
EXPOSE 80
EXPOSE 443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/nginx", "/var/log/nginx", "/var/www/html"]

CMD ["sh","/start/nginx.start"]
