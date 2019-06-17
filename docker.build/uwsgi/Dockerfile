#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="uWSGI via pip over openssh-server image"

COPY uwsgi.start wsgi_server.py /

RUN groupadd -g 10002 jenkins && \
    useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins && \
    set -ex && \
    apt-get update && \
    apt-get install -y python-pip build-essential python-dev --no-install-recommends && \
    apt-get clean && \
    pip install setuptools wheel && \
    pip install uwsgi && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    chmod 755 /uwsgi.start

# 9090 listen for connections / 9191 monitoring
EXPOSE 9090 
EXPOSE 9191

CMD ["/uwsgi.start"]
