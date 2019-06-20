## pytest and pyinstaller on python2 using pip

This image uses a python-dev installation over a simple image which is in turn on top of lrgc01/ssh-stretch_slim or debian:stretch-slim plus openssh server.

In this image it was added the command 'pip install pytest pyinstaller'.

The goal is to create an sshd server with these commands to be used by another server from the same container set like Jenkins service from a docker-compose, for example.


- See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

