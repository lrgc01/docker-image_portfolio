## python3-dev - an intermediate image build over a ssh-stable_slim image

Instead of build FROM debian:stable-slim this image is build over the same debian-slim plus an openssh-server.

This image is intended to be included in other image's FROM Dockerfile directive to save some space when sharing common instalations like python3 applications that need python3-dev, python3-pip, etc.

### Suggested docker-run commands:
 - This image is not intended to run like a normal container server.

