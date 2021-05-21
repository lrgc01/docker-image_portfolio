### mariadb container

 - Runs mariadb-server (latest version from meta package) over ssh-stable_slim image.
 - DB admin is root identified by 'docker' with grant option.
 - Connect using default port 3306.
 - Can use socket if sharing volume across containers.

See [https://lrc-tech.blogspot.com/2019/02/mysql-dockerfile-example.html](https://lrc-tech.blogspot.com/2019/02/mysql-dockerfile-example.html)

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)

