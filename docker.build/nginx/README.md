## nginx web server build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

### Suggested docker-run commands:
 - docker run -d --name=nginxAlone -v /etc/nginx:/etc/nginx -v /var/www/html:/var/www/html -v /var/log/nginx:/var/log/nginx --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 lrgc01/nginx-stretch_slim 

 - docker run -d --name=nginxProxied -v nginxcfg:/etc/nginx -v nginxhtml:/var/www/html -v nginxlogs:/var/log/nginx --publish 0.0.0.0:8880:80 --publish 0.0.0.0:4443:443 lrgc01/nginx-stretch_slim 

A container created from this image can share directories and connect to other containers to build a complete web server using, for instance, a php-fpm container server.

### Further useful examples

#### An approach that do similar container network is like this jenkins docker-compose:

 - See [https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html](https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html)

#### Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

