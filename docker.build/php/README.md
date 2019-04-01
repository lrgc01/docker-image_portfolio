### PHP + php-fpm build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

The goal is to create an sshd server with php software commands and php-fpm server to be used by another server from the same container set like Jenkins service from a docker-compose, for example.

- See https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html
