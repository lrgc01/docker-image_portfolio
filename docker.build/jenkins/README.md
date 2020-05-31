### This is jenkins from jenkins.io download page
- mounted over lrgc01/openjdk image

### Tips:
- Better combine with **lrgc01/scratch_maven** to use its volume and apache-maven binary.
- And with **lrgc01/pytest_pyinstaller** to make use of python build/test/installer commands within Jenkins container.
   - See https://lrc-tech.blogspot.com/2019/02/jenkins-in-docker-run-jenkins-python.html
- Suggested line to run, first with lrgc01/stratch_maven and then with lrgc01/jenkins after creating the maven volume:

```
root@dockersrv# docker create --name=maven -v maven-data:/opt/apache-maven-3.6.0 lrgc01/scratch_maven
root@dockersrv# docker run -d --name=jenkins --volumes-from=maven -v jenkins-data:/var/lib/jenkins --publish=0.0.0.0:8001:8080 --user=jenkins --workdir=/var/lib/jenkins lrgc01/jenkins
```

#### Note:
- Supposing the new container's name is "jenkins". This is a command to get initialAdminPassword to complete jenkins' installation:

```
root@dockersrv# docker exec -it jenkins cat /var/lib/jenkins/.jenkins/secrets/initialAdminPassword
```

