#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stable_slim:arm64

LABEL Comment="python3-pip over openssh-server image"

RUN set -ex && \
    apt-get update && \
    apt-get install -y python3-pip --no-install-recommends && \
    apt-get clean && \
    pip3 install setuptools wheel && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start

COPY start.sh /start/

CMD ["sh","/start/start.sh"]
