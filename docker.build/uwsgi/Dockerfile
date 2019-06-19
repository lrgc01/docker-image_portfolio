#
# This is a Dockerfile made from create.sh script - don't change here
#
FROM lrgc01/python_dev-stretch_slim

LABEL Comment="uWSGI via pip over openssh-server image"

RUN groupadd -g 10020 uwsgi && \
    useradd -m -u 10020 -g uwsgi -d /uwsgi.d uwsgi && \
    mkdir -p /uwsgi.d/appdir && chown -R 10020:10020 /uwsgi.d/appdir && \
    set -ex && \
    pip install setuptools wheel && \
    pip install uwsgi && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -fr /var/lib/apt/lists/* && \
    rm -fr /usr/share/man/man* 

# After creating user homedir
COPY --chown=10020:10020 uwsgi.start uwsgi.ini /uwsgi.d/
COPY --chown=10020:10020 uwsgi_server.py /uwsgi.d/appdir/

VOLUME ["/uwsgi.d"]


# 9090 listen for connections / 9191 monitoring
EXPOSE 9090 
EXPOSE 9191

CMD ["sh","/uwsgi.d/uwsgi.start"]
