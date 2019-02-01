### debootstrap base build script + various docker Dockerfile to build images

## Contents:

- debootstrap/create.sh - script to build an image from debootstrap command
- debootstrap/build - directory (**not uploaded**) to imagens - temporary
- docker.build - subdirectories with one Dockerfile each
  - postgresql - simple postgresql (latest) docker based on some stable base image made with debootstrap
  - mysql - simple mariadb-server-10.1 docker based on some stable base image made with debootstrap
  - rabbitmq - rabbitmq queue server
