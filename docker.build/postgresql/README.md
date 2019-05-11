## Postgresql on top of lrgc01/ssh-stretch_slim

- postgresql (latest from metapackage) on debian stretch 9 (stable) 
- by now on version 9.6
- based on lrgc01/ssh-stretch_slim

### Here is the Dockerfile:

```
FROM lrgc01/debian_stretch

# Install and keep thin
# Note: here we use &&\ to run commands one after the other - the \
#       allows the RUN command to span multiple lines.
RUN apt-get update && \
    apt-get install -y postgresql && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin

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
```

