#!/bin/bash
# Redis 3.2.9 installation script.
wget -O ~/redis-3.2.9.tar.gz http://download.redis.io/releases/redis-3.2.9.tar.gz
sudo tar -zxf ~/redis-3.2.9.tar.gz --directory=/usr/local
sudo mv /usr/local/redis-3.2.9 /usr/local/redis
cd /usr/local/redis
sudo make
/usr/local/redis/src/redis-server --version

echo -e 'OK, bye.\n'
