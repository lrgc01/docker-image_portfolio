### This image is based on the official debian:stretch-slim plus openssh-server

This image is intend to serve as base for command line only application that might be built as a separate container in order to be accessed by others linked inside the same dockerd environment.

An example could be a pytest+pyinstaller for a Jenkins server which issue a command wrapper instead of the real remote one.

- See https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html