#!/bin/bash
#Oracle JDK installation script.

#extract package
sudo tar -zxf jdk-*.tar.gz --directory=/usr/local
#rename floder
sudo mv /usr/local/jdk* /usr/local/jdk
#backup profile
sudo cp /etc/profile /etc/profile.old
#edit profile
sudo sed -i '$a export JAVA_HOME=/usr/local/jdk/\nexport JRE_HOME=/usr/local/jdk/jre\nexport CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib\nexport PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' /etc/profile
#Read and execute commands from /etc/profile
source /etc/profile
#print java info
echo "Java version info:"
java -version

echo -e '\nOK, bye.\n'