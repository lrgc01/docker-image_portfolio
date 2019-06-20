## uwsgi server build over a ssh-stretch_slim image

Instead of build FROM debian:stretch-slim this image is build over the same stretch-slim plus an openssh-server.

This powerful server works both as a Web server or as an application server using WSGI and uWSGI protocols. See [https://uwsgi-docs.readthedocs.io/en/latest/WSGIquickstart.html](https://uwsgi-docs.readthedocs.io/en/latest/WSGIquickstart.html)

### Suggested docker-run commands:

 - docker run -d --name=uwsgiAlone -v /var/run/uwsgi:/uwsgi.d --publish 0.0.0.0:80:9090 --publish 0.0.0.0:9191:9191 lrgc01/uwsgi-stretch_slim

 - docker run -d --name=uwsgiProxied -v uwsgicfg:/uwsgi.d --publish 0.0.0.0:9090:9090 --publish 0.0.0.0:9191:9191 lrgc01/uwsgi-stretch_slim
 
 - docker run -d --name=uwsgiSocket -v uwsgicfg:/uwsgi.d --publish 0.0.0.0:3131:3131 --publish 0.0.0.0:9191:9191 lrgc01/uwsgi-stretch_slim


### The main directory configuration

 - Every configuration were done in /uwsgi.d directory.

 - The main startup file: uwsgi.ini

   - Change /uwsgi.d/uwsgi.ini according to your needs (socket, port, web server, app to start, etc).


### Useful examples
 
Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

