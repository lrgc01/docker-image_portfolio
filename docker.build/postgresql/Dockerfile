#
# example Dockerfile from https://docs.docker.com/engine/examples/postgresql_service/
# with little improve
#

FROM lrgc01/ssh-stretch_slim

# Install and keep thin
# Note: here we use &&\ to run commands one after the other - the \
#       allows the RUN command to span multiple lines.
# Note2: clean some files that will be downloaded again on every "apt update" command.
# Note3: There is no man command on base docker image, so no man pages at all.
RUN apt-get update && \
    mkdir -p /usr/share/man/man1 /usr/share/man/man7 && \
    apt-get install -y postgresql postgresql-contrib --no-install-recommends && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man*/* 

# Run the rest of the commands as the postgres user created by the postgres-9.6 package when it was apt-get installed
USER postgres

# Create a PostgreSQL role named docker with docker as the password and
# then create a database docker owned by the docker role.
# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
# And add listen_addresses to /etc/postgresql/9.6/main/postgresql.conf
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker && \
    echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c", "config_file=/etc/postgresql/9.6/main/postgresql.conf"]
