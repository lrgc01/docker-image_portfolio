FROM lrgc01/openjdk
LABEL Comment="Jenkins over base + jdk environment"
ADD temp_tarball.tgz /
RUN groupadd -g 10002 jenkins &&     useradd -M -u 10002 -g jenkins -d /var/lib/jenkins jenkins &&     apt-get update &&     apt-get install -y git &&     apt-get clean &&     rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin &&     rm -f /var/lib/apt/lists/*debian.org* &&     rm -fr /usr/share/man/man* 
EXPOSE 8080
VOLUME  ["/var/lib/jenkins"]
CMD ["/usr/local/bin/jenkins"]
