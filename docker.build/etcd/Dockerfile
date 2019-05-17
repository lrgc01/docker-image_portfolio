#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/ssh-stretch_slim

LABEL Comment="etcd server over openssh-server image"

COPY etcd.start /

ADD https://storage.googleapis.com/etcd/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz /tmp/etcd.tgz

RUN mkdir /tmp/etcd.tmp && \
    tar -xf /tmp/etcd.tgz -C /tmp/etcd.tmp && \
    find /tmp/etcd.tmp -maxdepth 2 \( -name etcd -o -name etcdctl \) -type f -exec cp -p {} /usr/local/bin \; && \
    rm -fr /tmp/etcd.tgz /tmp/etcd.tmp && \
    chmod 755 /etcd.start

# Obvious Web ports
EXPOSE 2379
EXPOSE 2380

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etcd-data"]

CMD ["/etcd.start"]
