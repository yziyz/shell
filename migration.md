# OnlineJudge服务器迁移

## 1 安装Docker
> 注：在目的主机上操作；有时无法访问Docker官网，故无法使用软件源方式安装Docker，此处通过下载二进制文件安装。

### 1.1 下载二进制文件

在能够访问`https://download.docker.com`的主机下载，执行命令：
```
$ wget https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz
```
> 此处的`docker-18.03.1-ce.tgz`为18.03.1版本的二进制文件，若需要下载其他版本，可以查看`https://download.docker.com/linux/static/stable/x86_64/`

解压，执行命令：
```
$ tar zxvf docker-18.03.1-ce.tgz
```

将二进制文件移动到`/usr/bin`目录，执行命令：
```
sudo mv docker/* /usr/bin
```

### 1.2 通过Systemd管理Docker

切换目录到`/lib/systemd/system`，执行命令：
```
cd /lib/systemd/system
```

新建文件`docker.socket`，执行命令：
```
sudo vim docker.socket
```
粘贴如下内容：
```
[Unit]
Description=Docker Socket for the API
PartOf=docker.service

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
```
保存内容。

新建文件`docker.service`，执行命令：
```
sudo vim docker.service
```
粘贴如下内容：
```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket firewalld.service
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=-/etc/default/docker
ExecStart=/usr/bin/dockerd -H fd:// $DOCKER_OPTS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
```

启用上面两个文件，执行命令：
```
$ sudo systemctl enable docker.socket
$ sudo systemctl enable docker.service
```

启动docker程序，执行命令：
```
$ sudo systemctl start docker.service
```

### 1.3 安装Docker compose

执行命令：
```
$ sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
```
> 注：上述命令安装了1.21.2版本，若需要安装其他版本，请查看`https://github.com/docker/compose/releases`

为二进制文件添加执行权限，执行命令：
```
$ sudo chmod +x /usr/local/bin/docker-compose
```

## 2 迁移数据

### 2.1 打包数据目录
> 在原主机上操作

创建文件存放目录`~/oj_data`，执行命令：
```
mkdir ~/oj_data
```

> 由于数据文件数量较多，此处将目录打包并压缩成单个文件，提高传输效率。

打包原主机的`/home/log`/`/home/test_case`/`/home/upload`/`/home/OnlineJudge`目录到文件，执行命令（此处使用`--exclude`参数排除不需要打包的文件）：
```
$ sudo tar zcf data_$(date +%Y%m%d_%H%M%S).tgz /home --exclude=/home/cxj --exclude=/home/OnlineJudge.tar
```

为其他用户添加压缩包的读权限，执行命令：
```
$ sudo chmod +r data_20180601_153644.tgz
```
> 注：压缩包文件名称里包含了创建时间，请根据实际情况修改命令，下同

### 2.2 获取数据打包
> 在目的主机上操作

获取数据文件，执行命令：
```
$ scp -r cxj@192.168.74.134:~/oj_data ~/
```

解压缩，执行命令：
```
$ tar zxf data_20180601_153644.tgz
```

移动数据目录至`/home`，执行命令：
```
$ sudo mv home/* /home/
```

## 3 迁移容器

### 3.1 容器转为文件
> 在原主机上操作

查看当前容器，执行命令：
```
$ sudo docker ps -a
```
输出如下：
```
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                         NAMES
beff5d37fd65        5c9792e3619e          "nginx -g 'daemon ..."   13 months ago       Up 5 days           0.0.0.0:80->80/tcp, 443/tcp   ojwebserver_nginx_1
5eaad73d9773        qduoj/judger          "/bin/sh -c 'bash ..."   13 months ago       Up 5 days           0.0.0.0:8085->8080/tcp        judger_judger_1
ab2c3f149627        qduoj/oj_web_server   "/bin/sh -c 'bash ..."   13 months ago       Up 5 days           127.0.0.1:8080->8080/tcp      ojwebserver_oj_web_server_1
d892b0c1b99a        mysql                 "docker-entrypoint..."   13 months ago       Up 5 days           3306/tcp                      ojwebserver_mysql_1
86d3c1f498dd        redis                 "docker-entrypoint..."   13 months ago       Up 5 days           6379/tcp                      ojwebserver_redis_1
```

提交为镜像，执行命令（容器ID取决于上一段输出）：
```
$ sudo docker commit beff5d37fd65 nginx_dump
$ sudo docker commit 5eaad73d9773 judger_dump
$ sudo docker commit ab2c3f149627 oj_web_server_dump
$ sudo docker commit d892b0c1b99a mysql_dump
$ sudo docker commit 86d3c1f498dd redis_dump
```

查看新建的镜像，执行命令：
```
$ sudo docker images
```
输出如下：
```
REPOSITORY                                    TAG                 IMAGE ID            CREATED             SIZE
redis_dump                                    latest              16ad99c505ee        4 hours ago         185 MB
mysql_dump                                    latest              2fc3891bd50a        4 hours ago         383 MB
oj_web_server_dump                            latest              6532baae69a3        4 hours ago         783 MB
judger_dump                                   latest              361b105d2d56        4 hours ago         953 MB
nginx_dump                                    latest              d35962a12f83        4 hours ago         183 MB
（省略）
```

创建并切换镜像文件目录，执行命令：
```
$ mkdir ~/oj_images && cd ~/oj_images
```

将镜像保存为文件，执行命令：
```
$ sudo docker save nginx_dump > nginx_dump.tar
$ sudo docker save judger_dump > judger_dump.tar
$ sudo docker save oj_web_server_dump > oj_web_server_dump.tar
$ sudo docker save mysql_dump > mysql_dump.tar
$ sduo docker save redis_dump > redis_dump.tar
```

为其他用户添加镜像文件的读权限，执行命令：
```
$ sudo chmod +r *.tar
```

### 3.2 获取镜像文件
> 在目的主机上操作

获取镜像文件，执行命令：
```
$ scp -r cxj@192.168.74.134:~/oj_images ~/
```

加载并且标记镜像，执行命令（镜像ID取决于原主机的镜像信息）：
```
$ sudo docker load < nginx_dump.tar
$ sudo docker tag beff5d37fd65 nginx
$ sudo docker load < judger_dump.tar
$ sudo docker tag 5eaad73d9773 qduoj/judger
$ sudo docker load < oj_web_server_dump.tar
$ sudo docker tag 6532baae69a3 qduoj/oj_web_server
$ sudo docker load < mysql_dump.tar
$ sudo docker tag 2fc3891bd50a mysql
$ sudo docker load < redis_dump.tar
$ sudo docker tag 16ad99c505ee redis
```

查看当前镜像，执行命令：
```
$ sudo docker images
```
输出如下：
```
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
redis                 latest              16ad99c505ee        4 hours ago         185MB
mysql                 latest              2fc3891bd50a        4 hours ago         383MB
qduoj/oj_web_server   latest              6532baae69a3        4 hours ago         783MB
qduoj/judger          latest              361b105d2d56        4 hours ago         953MB
nginx                 latest              d35962a12f83        4 hours ago         183MB
```

## 4 启动容器
> 在目的主机上操作

切换路径至`/home/OnlineJudge/dockerfiles/oj_web_server/`，执行命令：
```
$ cd /home/OnlineJudge/dockerfiles/oj_web_server/
```

创建并启动`Web服务器`、`Redis`、`MySQL`和`Nginx`容器，执行命令：
```
$ cd /home/OnlineJudge/dockerfiles/oj_web_server/ 
$ sudo docker-compose -f docker-compose.yml -f docker-compose-nginx.yml up -d
```

创建并启动`判题服务器`容器，执行命令：
```
$ cd /home/OnlineJudge/dockerfiles/judger
$ sudo docker-compose up -d
```

使用浏览器访问`目的主机的80端口`，并登录账户，查看题目和提交，说明数据迁移完成。

## 5 修改判题服务器

由于`目的主机`上的数据完全来自`原主机`，需要修改`目的主机的判题服务器`为目的主机上的判题服务器，请使用OJ网站的root用户登录并修改。

## 6 参考文献

1.https://docs.docker.com/engine/reference/commandline/commit/#description

2.https://docs.docker.com/compose/extends/#example-use-case

3.https://docs.docker.com/compose/install/#install-compose

4.https://stackoverflow.com/questions/984204/shell-command-to-tar-directory-excluding-certain-files-folders?answertab=oldest#tab-top

5.https://unix.stackexchange.com/questions/46969/compress-a-folder-with-tar

