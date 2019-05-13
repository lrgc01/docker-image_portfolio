FROM lrgc01/ssh-stretch_slim

LABEL Comment="Azure linux CLI over openssh-server image"

RUN groupadd -g 10001 azgrp && \
    useradd -u 10001 -g azgrp -m -d /home/azure -s /bin/bash -p '$1$dCBYnSpg$8BkCq12tc7EUbBbC.a4qu1' azusr && \
    apt-get update && \
    apt-get install -y gnupg2 apt-transport-https lsb-release software-properties-common dirmngr --no-install-recommends && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv --keyserver packages.microsoft.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
    apt-get update && \
    apt-get install -y azure-cli --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]

