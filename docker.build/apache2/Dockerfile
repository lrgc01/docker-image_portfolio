#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="Apache2 web server over openssh-server image"

RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-fcgid libapache2-mod-proxy-uwsgi --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /run/php /start 

COPY apache2.start /start/

# Obvious Web ports
EXPOSE 80
EXPOSE 443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/apache2", "/var/log/apache2", "/var/www/html"]

CMD ["sh","/start/apache2.start"]
