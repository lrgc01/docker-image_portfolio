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
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin && \
    rm -f /var/lib/apt/lists/*debian.org* && \
    rm -fr /usr/share/man/man* && \
    sed -e 's/127.0.0.1/0.0.0.0/' < /etc/mysql/mariadb.conf.d/50-server.cnf > \
       /etc/mysql/mariadb.conf.d/50-server.cnf.new && \
    mv -f /etc/mysql/mariadb.conf.d/50-server.cnf.new /etc/mysql/mariadb.conf.d/50-server.cnf && \
    /usr/bin/mysqld_safe --nowatch && sleep 5 && \
    (echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'docker'" | mysql -u root) && \
    mysqladmin -u root shutdown

# Expose the Mysql/MariaDB port
EXPOSE 3306

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/mysql", "/var/log/mysql", "/var/lib/mysql"]

# Set the default command to run when starting the container
CMD ["/usr/bin/mysqld_safe"]
