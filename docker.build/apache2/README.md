## Apache2 web server build over a ssh-debian\_slim image

Instead of build FROM debian:stable-slim this image is build over the same stable-slim plus an openssh-server (lrgc01/ssh-debian\_slim here).

### Suggested docker-run commands:
 - docker run -d --name=apache2Alone -v /etc/apache2:/etc/apache2 -v /var/www/html:/var/www/html -v /var/log/apache2:/var/log/apache2 --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 lrgc01/apache2

 - docker run -d --name=apache2Proxied -v apache2cfg:/etc/apache2 -v apache2html:/var/www/html -v apache2logs:/var/log/apache2 --publish 0.0.0.0:8880:80 --publish 0.0.0.0:4443:443 lrgc01/apache2

### Some environment variables may be set to set apache2 at startup:

 - APACHE2\_MOD\_LIST - Space separated module name without any suffix:

 - docker run -d --name=apache2 -e APACHE2\_MOD\_LIST="proxy proxy\_uwsgi" --publish 0.0.0.0:8880:80 --publish 0.0.0.0:4443:443 lrgc01/apache2

A container created from this image can share directories and connect to other containers to build a complete web server using, for instance, a php-fpm container server.

### Useful examples

#### An approach that do similar container network is like this jenkins docker-compose:
 - See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)


#### Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

