#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python_dev-stretch_slim

LABEL Comment="Pytest n pyinstaller (python2) via pip over a python-dev image over an openssh-server image"

COPY python.start /

RUN groupadd -g 10002 jenkins && \
    useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins && \
    set -ex && \
    pip install pytest pyinstaller && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    chmod 755 /python.start

EXPOSE 22

CMD ["/python.start"]
