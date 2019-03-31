#

# Could be ubuntu
# or any official distribution in Docker Hub, like debian
# We use out own mininal base bootstrap made from debootstrap
FROM lrgc01/stretch_slim-ssh

# Install and keep thin
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
# Note1: Create mysql group and user with unprobable UID/GID 336 (mysql's port without 0)
# Note2: clean some files that will be downloaded again on every "apt update" command.
# Note3: There is no man command on base docker image, so no man pages at all.
# Note4: Make sure all hosts have access to this docker mysql-server
# Note5: Once running, grant all privileges to root from anywhere which docker password.
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    mkdir /run/php

EXPOSE 80
EXPOSE 443

# Add VOLUMEs to allow backup of config, logs and other (this is a best practice)
VOLUME  ["/etc/nginx", "/var/log/nginx", "/var/www/html"]

# Set the default command to run when starting the container
CMD ["/usr/sbin/nginx","-g","daemon off;","-c","/etc/nginx/nginx.conf"]
