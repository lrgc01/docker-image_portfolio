### Various Dockerfile to build Docker images plus a debootstrap (debian) base build script 

## Contents:

- debootstrap/create.sh - script to build an image using debootstrap command
- debootstrap/build - directory (**not uploaded**) to images - temporary
- docker.build - subdirectories with one Dockerfile each
  - jenkins - Jenkins only build on top of openjdk image
  - openssh - base debian stable slim with openssh-server installed to be used by many other applications
  - node - node js on top of openssh image
  - php - php and fpm on top of openssh image
  - maven - maven tree only to be shared as a volume and used by Jenkins or whatever
  - nginx - nginx httpd server on top of openssh and that may use the php image
  - postgresql - simple postgresql (latest) docker based on some stable base image made with debootstrap
  - mysql - simple mariadb-server docker based on some stable base image made with debootstrap
  - etcd - etcd server built by downloading from storage.googleapis.com
  - and many others...

Many times there is also the *create.sh* shell script. It is used to generate the Dockerfile and sometimes 
to create a directory hierarchy or even some shell scripts like a command wrapper or a container
startup command.
