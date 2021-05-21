#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stable_slim

LABEL Comment="samba CIFS server"

RUN apt-get update && \
    apt-get install -y samba winbind --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* && \
    mkdir -p /start.d 

COPY samba.bootstrap  /start.d/

# Obvious Web ports and others
EXPOSE 137
EXPOSE 138
EXPOSE 139
EXPOSE 445

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/samba", "/var/log/samba" ]

CMD ["sh","/start.d/samba.bootstrap"]
