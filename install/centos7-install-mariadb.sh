#!/bin/bash
#MariaDB-10.2.6 installation scropt.

#Create repo file
echo -e "[mariadb]\nname = MariaDB\nbaseurl = https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.2.6/yum/centos7-amd64/\ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck=1" > temp
sudo cp temp /etc/yum.repos.d/MariaDB.repo
rm temp
#Make cache
sudo yum makecache
#Install
sudo yum -y install MariaDB-server MariaDB-client
#Start
sudo systemctl start mariadb
#Promote user to config MariaDB
echo -e "MariaDB installed and started, please run:\nmysqladmin -u root password\nto set root passwd.\n"

echo -e 'OK, bye.\n'
