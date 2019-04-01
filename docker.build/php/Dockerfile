#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/stretch_slim-ssh

LABEL Comment="PHP and php-fpm software + server over openssh-server image"

COPY php.start /

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql && \
    apt-get clean && \
    pip3 install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir /run/php && \
    chmod 755 /php.start

# If someone wants TCP instead of socket
EXPOSE 9000

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/run/php","/etc/php"]

CMD ["/php.start"]
