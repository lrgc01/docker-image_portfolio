FROM lrgc01/ssh-debian_slim

LABEL Comment="Adding jdk on top of base image"

# Workaround to avoid install error when linking man page
RUN apt-get update && \
    mkdir -p /usr/share/man/man1 ; \
    apt-get install -y default-jdk-headless && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man*/*

VOLUME ["/usr/lib/jvm"]

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
