#

# Could be ubuntu
# or any official distribution in Docker Hub, like debian
# We use out own mininal base bootstrap made from debootstrap
#FROM lrgc01/minbase_stable
FROM jre

COPY jenkins* /

# Install and keep thin
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
# Note2: clean some files that will be downloaded again on every "apt update" command.
# Note3: There is no man command on base docker image, so no man pages at all.
RUN apt-get update && \
    apt-get install -y daemon procps psmisc net-tools && \
    apt-get clean && \
    dpkg -i /jenkins_2.150.2_all.deb ; \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    rm -f /jenkins_2*.deb

# Expose the Jenkins default port
EXPOSE 8080

# Add VOLUMEs 
VOLUME  ["/var/lib/jenkins"]

# Set the default command to run when starting the container
CMD ["/jenkins","start"]
