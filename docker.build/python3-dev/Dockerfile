#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="python3-dev over openssh-server image"

RUN set -ex && \
    apt-get update && \
    apt-get install -y python3-pip build-essential python3-dev --no-install-recommends && \
    apt-get clean && \
    pip3 install setuptools wheel && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

CMD ["sh","/conf.d/fake.start"]
