#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stable_slim

LABEL Comment="PHP and php-fpm software + server over openssh-server image"

RUN groupadd -g 10002 jenkins && \
    useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins && \
    set -ex && \
    apt-get update && \
    apt-get install -q -y php php-fpm php-mysql php-gd php-curl php-mbstring php-intl php-xml php-zip --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man*/* && \
    mkdir -p /run/php /start

COPY php.start /start/

# If someone wants TCP instead of socket
EXPOSE 9000

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/run/php","/etc/php"]

CMD ["sh","/start/php.start"]
