FROM debian:stable-slim

RUN set -ex \
    && apt-get update && apt-get install -q -y net-tools tcpdump iproute2 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove

CMD [ "/bin/bash","-i" ]
