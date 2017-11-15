#!/bin/bash

##配置参数
#工作路径
WORK_PATH="/opt/cato/"
#JAR文件路径
JAR_PATH="cato-1.0.jar"
#启动类型
TYPE=""
#日志文件路径
LOG_PATH="log/cato.log"
#等待时间
WAIT_SECONDS=20
#命令
CMD="java -Djava.security.egd=file:///dev/urandom -jar "$JAR_PATH"

##启动逻辑
#切换路径
cd $WORK_PATH
#判断日志文件是否存在
if [ ! -e "$LOG_PATH" ] ; then
	echo -e "创建日志文件夹"
	mkdir log
	touch $LOG_PATH
fi
#判断JAR文件是否存在
if [ ! -e "$JAR_PATH" ] ; then
        #若不存在，报错并退出
        echo -e "\n操作时间："`date`"\n错误：文件"$JAR_PATH"不存在" >> $LOG_PATH
        tail -n 2 $LOG_PATH
        exit 1
fi
#获取程序的进程号
PID=`ps -ef | grep $JAR_PATH | grep -v grep | awk '{print $2}'`
#判断进程是否存在
if [[ "$PID" -eq "" ]] ; then
        #若不存在，则是启动
        TYPE="启动\n"
else
        #否则是重启
        TYPE="重启\n"
        #停止进程
        kill $PID
      	sleep $WAIT_SECONDS
fi
#启动
nohup $CMD > /dev/null 2>&1 &
#提示信息
echo -e "\n操作时间："`date "+%Y-%m-%d %H:%M:%S"`"\n操作类型："$TYPE >> $LOG_PATH
#打印日志
tail -n 3 -f $LOG_PATH
