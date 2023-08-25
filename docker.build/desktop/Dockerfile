#
FROM lrgc01/debian-nox11:arm64

COPY bootstrap.container.sh /

RUN set -ex \
    && sed -i '/path-exclude \/usr\/share\/man/d' /etc/dpkg/dpkg.cfg.d/docker \
    && sed -i '/path-exclude \/usr\/share\/groff/d' /etc/dpkg/dpkg.cfg.d/docker \
    && apt-get update \
    && apt-get install -q -y xorg xrdp xfce4 xfce4-goodies openbox dbus-x11 policykit-1 \
    && apt-get install -q -y gnome fuse3 gvfs-fuse \
    && apt-get install -q -y firefox-esr libreoffice freerdp2-x11 mpv \
    && apt-get purge -y --auto-remove \
    && apt-get clean \
    && mkdir /run/sshd

CMD [ "/bootstrap.container.sh" ]

ENTRYPOINT [/init]


