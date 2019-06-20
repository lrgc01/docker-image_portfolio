#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python3_dev-stretch_slim

LABEL Comment="Pytest n pyinstaller via pip3 over python3-dev over openssh-server image"

COPY python.start /

RUN groupadd -g 10002 jenkins && \
    useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins && \
    set -ex && \
    pip3 install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    chmod 755 /python.start

EXPOSE 22

CMD ["/python.start"]
