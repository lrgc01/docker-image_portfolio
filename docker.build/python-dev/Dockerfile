#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="python-dev over openssh-server image"

RUN set -ex && \
    apt-get update && \
    apt-get install -y python-pip build-essential python-dev --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

CMD ["sh","/conf.d/fake.start"]
