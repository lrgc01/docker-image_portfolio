#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/php:arm64

LABEL Comment="Dolibarr via PHP composer on top of php (slim) image"

RUN mkdir -p /data/work && \
    chown -R www-data /data && \
    set -ex && \
    apt update -q && \
    apt upgrade -q -y && \
    apt install zip unzip php-xml php-curl php-mbstring php-intl php-gd composer -y -q && \
    su -l -s /bin/bash -c "composer create-project dolibarr/dolibarr --working-dir /data/work" www-data && \
    su -l -s /bin/bash -c "composer clear-cache --working-dir /data/work" www-data && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

VOLUME ["/data/work"]

#CMD ["sh","/data/php.start"]
