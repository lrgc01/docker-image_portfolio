## python-dev intermediate image build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

This image is intended to be included in other image's FROM Dockerfile directive to save some space when sharing common instalations like python applications that need python-dev, python-pip, etc.

### Suggested docker-run commands:
 - This image is not intended to run like a normal container server.

