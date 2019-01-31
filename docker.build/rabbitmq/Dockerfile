#

FROM lrgc01/debootstrap-minb-debian9

# Install and keep thin
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
# Note2: clean some files that will be downloaded again on every "apt update" command.
# Note3: There is no man command on base docker image, so no man pages at all.
# Note4: Make sure all hosts have access to this docker mysql-server
# Note5: Once running, grant all privileges to root from anywhere which docker password.
RUN apt-get update && \
    apt-get install -y rabbitmq-server && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 

# Expose the rabbitmq ports
EXPOSE 25672
EXPOSE 4369
EXPOSE 5671
EXPOSE 5672

# Set the default command to run when starting the container
CMD ["/etc/init.d/rabbitmq-server","start"]
