FROM lrgc01/jre
LABEL Comment="This image is used to start the maven on demand from ssh"
ENV PATH /opt/apache-maven-3.6.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY opt /opt
RUN apt-get update &&     apt-get install -y openssh-server &&     apt-get clean &&     rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin &&     rm -f /var/lib/apt/lists/*debian.org* &&     rm -fr /usr/share/man/man* 
VOLUME ["/opt/apache-maven-3.6.0"]
EXPOSE 22
CMD ["/etc/init.d/ssh","start","-D"]
