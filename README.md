### Various Dockerfile to build Docker images

## Contents:

- docker.build - subdirectories ordered by dependency with one Dockerfile each
  - ssh - debian/ubuntu/kali slim with openssh-server - base for all
  - node - node js on top of openssh image
  - php - php and fpm on top of openssh image
  - maven - maven tree only to be shared as a volume and used by Jenkins or whatever
  - jenkins - Jenkins only build on top of openjdk image
  - nginx - nginx httpd server on top of openssh and that may use the php image
  - postgresql - simple postgresql (latest) docker based on some stable base image made with debootstrap
  - mysql - simple mariadb-server docker based on some stable base image made with debootstrap
  - and many others...

Many times there is also the *create.sh* shell script. It is used to generate the Dockerfile and sometimes 
to create a directory hierarchy or even some shell scripts like a command wrapper or a container
startup command.

## Hierarchy

![Hierarchy](Hierarchy.png)
