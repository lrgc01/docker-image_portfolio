#

# Could be ubuntu
# or any official distribution in Docker Hub, like debian
# We use out own mininal base bootstrap made from debootstrap
FROM lrgc01/minbase_stable_debian9

# Install and keep thin
# Note: here we use &&\ to run commands one after the other - the \
#       allows the RUN command to span multiple lines.
# Note2: clean some files that will be downloaded again on every "apt update" command.
# Note3: There is no man command on base docker image, so no man pages at all.
RUN apt-get update && \
    apt-get install -y openjdk-8-jre-headless && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* 

# Expose some default port
EXPOSE 8080

# Add VOLUMEs 
VOLUME  ["/var/lib/jre"]

# Set the default command to run when starting the container
CMD ["/bin/bash"]
