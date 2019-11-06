#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM debian3:5000/php-stretch_slim

LABEL Comment="Dolibarr via PHP composer on top of php-stretch_slim image"

RUN mkdir -p /var/www && \
    chown -R www-data /var/www && \
    set -ex && \
    apt update -q && \
    apt upgrade -q -y && \
    apt install zip unzip php-xml php-curl php-mbstring php-intl php-gd composer -y -q && \
    su -l -s /bin/bash -c "composer create-project dolibarr/dolibarr --working-dir /var/www" www-data && \
    su -l -s /bin/bash -c "composer clear-cache --working-dir /var/www" www-data && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

VOLUME ["/var/www"]

#CMD ["sh","/var/www/php.start"]
