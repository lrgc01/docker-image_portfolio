#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python3-dev

LABEL Comment="Pytest and pyinstaller via pip3 over python3-dev over openssh-server image"

RUN groupadd -g 10002 jenkins && \
    useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins && \
    set -ex && \
    pip3 install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p start

COPY python.start start/

EXPOSE 22

CMD ["sh","start/python.start"]
