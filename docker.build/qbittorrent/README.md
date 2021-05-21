## qbittorrent - build on top of python3-pip

This image is based on python3-pip which in turn was built on top of debian stable plus sshd.


### Suggested docker-run commands:
sudo docker run -dit -p 0.0.0.0:8080:8080 -v /data2/qbittorrent:/data -e "DOCKER_START_SH=qbittorrent-nox" --name=qbittorrent lrgc01/qbittorrent

Where /data may be a dedicated space to download and share files.

