### Various Dockerfile to build Docker images

## Contents:

- docker.build/###-servicename - subdirectories ordered by dependency with one Dockerfile each
  - __ssh__ - debian/ubuntu/kali slim with openssh-server - base for all
  - __node__ - node extracted as is from its original Dockerfile and slightly changed
  - __php__ - php and fpm on top of openssh image
  - __jenkins__ - Jenkins-only build on top of openjdk image
  - __nginx__ - nginx httpd server on top of openssh image
  - __postgresql__ - simple postgresql (latest) docker based on some stable base image
  - __oci_cli__ - Oracle Cloud (python) CLI with its Dockerfile inspired in its original from Oracle official docker itself
  - __gcloud_cli__ - GCP (python) CLI with its Dockerfile inspired in its original from Google Cloud official docker itself
  - __mariadb__ - simple mariadb-server docker based on some stable base image
  - and many others...

Each image definition has the *create.sh* shell script. It is used to generate the Dockerfile and sometimes 
to create a directory hierarchy or even some shell scripts like a command wrapper or a container
startup command. (See above).

## Hierarchy

![Hierarchy](Hierarchy.png)

## Base script set

Each subdirectory under *docker.build* named *###-servicename* has a global linked script plus a local
configuration.

- __create.sh__ - link to ../scripts/create.sh - Main engine that loads local
  configuration, assembly the Dockerfile, maybe other files like startup scripts, and runs docker
  builder.
- __local.rc__ - local configuration file with particularities of each deploy
- __README.md__ (optional) - explains specific details for each image
- __lastid.**__ - automaticaly created file to track each build to avoid building an image which dependency
  didn't change.
