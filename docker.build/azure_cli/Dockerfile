FROM lrgc01/ssh-stable_slim:arm64

LABEL Comment="Azure linux CLI over openssh-server image"

RUN groupadd -g 10001 azgrp && \
    useradd -u 10001 -g azgrp -m -d /home/azure -s /bin/bash -p '$1$foVWc/O3$q/i/.6x5e6Wpk8FooUk2Q.' azusr && \
    apt-get update && \
    apt-get install -y curl gnupg2 apt-transport-https lsb-release software-properties-common dirmngr ca-certificates --no-install-recommends && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=arm64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y azure-cli --no-install-recommends && \
    apt-get remove -y --autoremove curl gnupg2 apt-transport-https lsb-release software-properties-common dirmngr ca-certificates && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man*/* 

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]

