#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM debian3:5000/php-stretch_slim

LABEL Comment="PHP composer on top of php-stretch_slim image"

RUN mkdir -p /data/work && \
    chown -R www-data /data && \
    set -ex && \
    apt update -q && \
    apt upgrade -q -y && \
    apt install zip unzip php-xml php-curl php-mbstring php-intl php-gd composer php-zip php-mcrypt -y -q --no-install-recommends && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

VOLUME ["/data/work"]

#CMD ["sh","/data/php.start"]
