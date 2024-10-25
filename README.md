### Various Dockerfile to build Docker images

## Contents:

- docker.build/###-servicename - subdirectories ordered by dependency with one Dockerfile each
  - **ssh** - debian/ubuntu/kali slim with openssh-server - base for all
  - **git** - base git used as FROMIMG in many other programs like node, php,etc
  - **node** - node extracted as is from its original Dockerfile and slightly changed to use git image
  - **php** - php and fpm on top of git image
  - **openjre** - openJRE on top of git image
  - **openjdk** - openJDK on top of openjre image
  - **jenkins** - Jenkins-only on top of openjdk image
  - **nginx** - nginx httpd server on top of openssh image
  - **oci_cli** - Oracle Cloud (python) CLI with its Dockerfile inspired in its original from Oracle official docker itself
  - **gcloud_cli** - GCP (python) CLI with its Dockerfile inspired in its original from Google Cloud official docker itself
  - **mariadb** - simple mariadb-server docker based on some stable base image
  - and many others...

Each image definition has the _create.sh_ shell script. It is used to generate the Dockerfile and sometimes 
to create a directory hierarchy or even some shell scripts like a command wrapper or a container
startup command. (See above).

## Hierarchy

Hierarchy on which all docker dependency are planned and built.

![Hierarchy](Hierarchy.png)

## Base script set

Each subdirectory under _docker.build_ named _###-servicename_ has a global linked script plus a local
configuration.

- **create.sh** - link to ../scripts/create.sh - Main engine that loads local
  configuration, assembly the Dockerfile, maybe other files like startup scripts, and runs docker
  builder.
- **local.rc** - local configuration file with particularities of each deploy
- **README.md** (optional) - explains specific details for each image
- __lastid.\*__ - automaticaly created file to track each build to avoid building an image in which dependency
  didn't change.

### Subdirectory scripts

- **build.sh** - not used - deprecated
- **create.sh** - main engine to prepare and build images
- **periodic.sh** - build whole hierarchy or a subset - useful in periodic crontab jobs
- **docker-entrypoint.sh** - (work in progress) - tip from node (official) that is agnostic as an entrypoint and very useful to exec containers as if it were the native command
- **generic.rc** - main variable definition
- **etc-X11-s6.tgz** - main set of S6 based scripts to run a desktop inside a container - check _090-distrib-desktop_
