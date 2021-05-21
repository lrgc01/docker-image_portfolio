#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python3-pip

LABEL Comment="qbittorrent using python3-pip image"

RUN set -ex && \
    groupadd -g 1000 qbittorrent && \
    useradd -M -u 1000 -g qbittorrent -d /data qbittorrent && \
    apt-get update && \
    apt-get install -y qbittorrent-nox --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /data


COPY start.sh /data/

CMD ["sh","/data/start.sh"]
