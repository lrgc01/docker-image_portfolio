#FROM debian:stable-slim
FROM lrgc01/ssh-stable_slim

RUN set -ex \
    && apt-get update && apt-get install -q -y net-tools tcpdump iproute2 --no-install-recommends \
    && apt-get install -q -y curl \
    && apt-get purge -y --auto-remove \
    && rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin  \
    && rm -fr /usr/share/man/man*  \
    && rm -rf /var/lib/apt/lists/* 

CMD [ "/usr/sbin/sshd","-D" ]
