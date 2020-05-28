## Simple Node.js from *node* built over a openssh-server

This image was built on top of lrgc01/ssh-debian_slim, or debian:debian-slim plus an openssh-server.

Nothing really new. Just a copy of [https://github.com/nodejs/docker-node](https://github.com/nodejs/docker-node) plus some small changes. These changes include a new user named "jenkins/10002" to match the one in other containers that are planned to work together (link) and the ssh server explained above. Another change in the Dockerfile is the CMD that is based on a new script.

The goal is to create an sshd server with Node.js commands to be used by another server from the same container set like Jenkins service from a docker-compose, for example.

Some variables that may be used when running this container:

 - DOCKER\_START\_SH - extra shell script that will be executed if existing and inside WORKDIR, if existing
 - DOCKER\_WORKDIR - the workdir to keep the above script (the shell will chdir to it)

### Examples

- See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

