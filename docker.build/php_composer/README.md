### PHP composer using a PHP + php-fpm build over a ssh-stretch_slim image

Take a look in [https://hub.docker.com/repository/docker/lrgc01/php-stretch_slim](https://hub.docker.com/repository/docker/lrgc01/php-stretch_slim). 

This is just a more complete set o PHP tools (in this case with composer) to run a PHP server and / or start a specific application.

Some variables that may be used when running this container:

 - DOCKER\_START\_SH - extra shell script that will be executed if existing and inside WORKDIR, if existing
 - DOCKER\_WORKDIR - the workdir to keep the above script (the shell will chdir to it)

### Examples

Another possibility (but not well tested) is this Jenkins service from a docker-compose example in this URL:

- See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)
