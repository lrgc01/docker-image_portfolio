## HAproxy high availability / load balancer server built over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

### Suggested docker-run commands:
 - docker run -d --name=haserver -v /etc/haproxy:/etc/haproxy -v /var/log/haproxy:/var/log/haproxy --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 lrgc01/haproxy-stretch_slim 

### Further useful examples

#### Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

