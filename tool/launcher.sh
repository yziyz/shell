#!/usr/bin/env bash

##参数
#工作路径
WORK_PATH="/d/omts/"
#JAR文件路径
JAR_PATH="omts-1.0.jar"
#命令
CMD="java -Dfile.encoding=UTF8 -Duser.language=en -Duser.region=US -jar ${JAR_PATH}"

##函数
#运行
function start() {
    local pid=$(jps -lm | grep -a ${JAR_PATH} | awk '{print $1}')
    if [[ ${pid} != "" ]]
    then
        echo -e "错误：程序正在运行\n"
        exit 1
    else
        nohup ${CMD} > /dev/null 2>&1 &
        pid=$(jps -lm | grep -a ${JAR_PATH} | awk '{print $1}')
        echo -e "运行，进程为${pid}"
    fi
}

#重启
function restart() {
    local pid=$(jps -lm | grep -a ${JAR_PATH} | awk '{print $1}')
    if [[ ${pid} == "" ]]
    then
        start
    else
        stop
        sleep 10
        start
    fi
}

#停止
function stop() {
    local pid=$(jps -lm | grep -a ${JAR_PATH} | awk '{print $1}')
    if [[ ${pid} == "" ]]
    then
        echo -e "错误：程序没有运行\n"
        exit 1
    else
        echo -e "停止，杀死进程${pid}"
        #若为WINDOWS
        taskkill //pid ${pid} //f //t > /dev/null
        #若为Linux
        #kill ${pid}
    fi
}

#判断JAR文件是否存在
function check_jar() {
    if [ ! -e ${JAR_PATH} ]
    then
        #若不存在，报错并退出
        echo -e "错误：文件 ${JAR_PATH} 不存在"
        exit 1
    fi
}

##启动逻辑
#切换路径
cd ${WORK_PATH}
#判断JAR文件是否存在
check_jar
#判断参数
if [[ $1 == "start" ]]
then
    start
elif [[ $1 == "restart" ]]
then
    restart
elif [[ $1 == "stop" ]]
then
    stop
else
    echo -e "参数：\n    start - 运行\n    restart - 重启\n    stop - 停止\n"
    exit 1
fi
exit 0
