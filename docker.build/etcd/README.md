### etcd container

 - Check create.sh in the same directory
 - Uses basic intructions extracted from [https://github.com/etcd-io/etcd/releases](https://github.com/etcd-io/etcd/releases)
 - Now at version 3.3.13
 - Exposes ports 2379 and 2380
 - Creates a volume /etcd-data
 - Uses a custom startup command in the same directory: etcd.start

Other similar docker examples together with some explanation can be found in:

 - [https://lrc-tech.blogspot.com/p/blog-page.html](https://lrc-tech.blogspot.com/p/blog-page.html)
