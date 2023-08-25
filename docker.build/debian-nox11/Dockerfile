#
FROM debian:stable-slim

ARG S6_OVERLAY_VERSION=3.1.5.0

#COPY bootstrap.container.sh /

RUN set -ex \
    && sed -i '/path-exclude \/usr\/share\/man/d' /etc/dpkg/dpkg.cfg.d/docker \
    && sed -i '/path-exclude \/usr\/share\/groff/d' /etc/dpkg/dpkg.cfg.d/docker \
    && apt-get update \
    && apt-get install -q -y --reinstall man coreutils net-tools tcpdump iproute2 \
    && apt-get install -q -y xz-utils net-tools tcpdump screen tmux sudo apt-utils vim bc openssh-server \
    && apt-get install -q -y git unzip p7zip-full netcat-traditional \
    && apt-get purge -y --auto-remove \
    && apt-get clean \
    && mkdir /run/sshd

#CMD [ "/bootstrap.container.sh" ]

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz \
    && rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-aarch64.tar.xz

ENTRYPOINT [/init]


