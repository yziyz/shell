#!/bin/bash
#nginx 1.12.0 installation script.

yum -y install gcc automake autoconf libtool make
yum -y install gcc gcc-c++

#install pcre
cd /usr/local/src
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz
tar -zxf pcre-8.40.tar.gz
cd pcre-8.40
./configure
make
make install

#install zlib
cd /usr/local/src
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install

#install ssl
cd /usr/local/src
wget https://www.openssl.org/source/openssl-1.1.0e.tar.gz
tar -zxf openssl-1.1.0e.tar.gz
cd openssl-1.1.0e
./config
make
make install

#install nginx
cd /usr/local/src
wget http://nginx.org/download/nginx-1.12.0.tar.gz
tar -zxf nginx-1.12.0.tar.gz
cd nginx-1.12.0
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-http_ssl_module --with-pcre=/usr/local/src/pcre-8.40 --with-zlib=/usr/local/src/zlib-1.2.11 --with-openssl=/usr/local/src/openssl-1.1.0e
make
make install

echo -e 'OK, bye.\n'