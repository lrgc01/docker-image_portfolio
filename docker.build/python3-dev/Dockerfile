#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python3-pip

LABEL Comment="python3-dev over python3-pip image"

RUN set -ex && \
    apt-get update && \
    apt-get install -y build-essential python3-dev --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start

COPY start.sh /start/

CMD ["sh","/start/start.sh"]
