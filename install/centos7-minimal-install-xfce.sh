#!/bin/bash
#From http://www.server-world.info/en/note?os=CentOS_7&p=x&f=8
sudo yum -y groups install "Server with GUI"
sudo yum --enablerepo=epel -y groups install "Xfce"
sudo echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc

echo -e 'OK, bye.\n'
