FROM debian:stretch-slim

RUN set -ex \
    && apt-get update && apt-get install -y openssh-server --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove $buildDeps \
    && mkdir /run/sshd

EXPOSE 22

CMD [ "/usr/sbin/sshd","-D" ]
