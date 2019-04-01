### nginx web server build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

A container created from this image can share directories and connect to other containers to build a complete web server using, for instance, a php-fpm container server.

#### An approach that do similar container network is like this jenkins docker-compose:
- See https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html
