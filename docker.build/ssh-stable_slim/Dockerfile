FROM debian:stable-slim

RUN set -ex \
    && apt-get update && apt-get install -q -y openssh-server --no-install-recommends \
    && apt-get purge -y --auto-remove \
    && useradd -m -s /bin/bash admin \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin  \
    && rm -fr /usr/share/man/man*  \
    && mkdir /run/sshd

EXPOSE 22

CMD [ "/usr/sbin/sshd","-D" ]
