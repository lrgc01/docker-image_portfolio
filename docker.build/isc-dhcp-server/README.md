## ISC DHCP server built over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

### Suggested docker-run commands:
 - docker run -d --name=dhcp -v /etc/dhcp:/etc/dhcp -v /var/log/dhcp:/var/log/dhcp --network=host lrgc01/isc-dhcp-server

### Further useful examples

#### Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

