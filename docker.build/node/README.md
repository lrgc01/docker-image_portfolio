### Simple Node.js from *node* built over a openssh-server

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

The goal is to create an sshd server with Node.js commands to be used by another server from the same container set like Jenkins service from a docker-compose, for example.

- See https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html
