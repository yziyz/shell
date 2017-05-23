#!/bin/bash
#Pyhton 3.5.3 installation script.

sudo yum install -y automake autoconf libtool make gcc gcc-c++ openssl-devel
sudo wget -O /usr/local/src/Python-3.5.3.tar.xz http://mirrors.sohu.com/python/3.5.3/Python-3.5.3.tar.xz
sudo tar Jxf /usr/local/src/Python-3.5.3.tar.xz --directory=/usr/local/src
sudo rm /usr/local/src/Python-3.5.3.tar.xz
cd /usr/local/src/Python-3.5.3
sudo ./configure --prefix=/usr/local/python3
make
sudo make install
sudo ln -s /usr/local/python3/bin/python3 /usr/bin/python3
sudo ln -s /usr/local/python3/bin/pip3.5 /usr/bin/pip3
mkdir ~/.pip
touch ~/.pip/pip.conf
echo -e "[global]\nindex-url = http://mirrors.aliyun.com/pypi/simple\n[install]\ntrusted-host=mirrors.aliyun.com" > ~/.pip/pip.conf
sudo pip3 install --upgrade pip
python3 -V

echo -e 'OK, bye.\n'