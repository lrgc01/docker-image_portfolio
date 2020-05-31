### Azure CLI container

 - Built using the installations instructions from Microsoft Azure itself.
   - See: [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
 - This image is based on lrgc01/ssh-debian\_slim, or the official debian:stable-slim plus the openssh-server.
 - Connect using SSH port 22 or anyone chosen by --publish directive.
 - User is not root, instead it is "azusr" identified by 'DockerAz123' with no sudo privileges.
 - Very useful if running locally with docker exec for example - Don't forget to login and logout from Azure cloud.

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)
