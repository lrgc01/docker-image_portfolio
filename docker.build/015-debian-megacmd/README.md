## megacmd CLI downloaded from mega.io (Mega.nz)

Image built on top of debian-net image.

### Suggested docker-run commands:
 - docker run -d --name=megacmd -v ~/.megacmd:/home/admin/.megacmd --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 lrgc01/debian-megacmd

A container created from this image will expose a webdav service to the net.

