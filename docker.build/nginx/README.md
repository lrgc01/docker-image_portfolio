### nginx web server build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

A container created from this image can share directories and connect to other containers to build a complete web server using, for instance, a php-fpm container server.

#### An approach that do similar container network is like this jenkins docker-compose:
- See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

