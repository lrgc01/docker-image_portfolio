## Samba CIFS server built over a ssh-stable\_slim image

Instead of build FROM debian:stable-slim this image is build over the same stable-slim plus an openssh-server.

### Suggested docker-run commands:
 - docker run -d --name=samba -v /etc/samba:/etc/samba -v /var/log/samba:/var/log/samba --publish 0.0.0.0:137:137/udp --publish 0.0.0.0:138:138/udp --publish 0.0.0.0:139:139 --publish 0.0.0.0:445:445 lrgc01/samba

### Further useful examples

#### Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

