### Simple ruby from official *ruby* built over a openssh-server

This image was built on top of lrgc01/ssh-debian, or debian:debian-slim plus an openssh-server.

Nothing is really new. Just a copy of [https://github.com/docker-library/ruby](https://github.com/docker-library/ruby) plus some small changes. These changes include a new user named "jenkins/10002" to match the one in other containers that are planned to work together (link) and the ssh server explained above.

The goal is to create an sshd server with some Ruby basic commands to be used by another server from the same container set like Jenkins service from a docker-compose, for example.

- See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

