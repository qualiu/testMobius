#!/bin/bash
ShellDir=$(cd $(dirname $0) && pwd)
if [ ! -e "$SPARKCLR_HOME" ]; then
    export SPARKCLR_HOME=$ShellDir/../../../build/runtime
fi

function CheckExist() {
    path=$1
    description=$2
    if [ -z "$path" ]; then
        echo "Not exist $description : $path"
        exit
    fi
}

CheckExist "$SPARKCLR_HOME"
CheckExist "$SPARKCLR_HOME/scripts/sparkclr-submit.sh"
TestExePath=$(find $ShellDir -type f -name *.exe | egrep -ie Kafka | egrep -v vshost | xargs ls -crt | tail -n 1)

CheckExist "$TestExePath" "test stream exe"

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "No parameter, Usage as following, run : $TestExePath"
    $TestExePath
    echo "Example parameters : WindowSlideTest -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -v 50 -c /tmp/checkDir -d 1 "
    echo "Test usage just run : $TestExePath"
    exit
fi

ExeDir=$(dirname $TestExePath)
ExeName=$(basename $TestExePath)

cd $ExeDir
jars=$SPARKCLR_HOME/dependencies/spark-streaming-kafka-assembly_2.10-1.6.1.jar
options="--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g"
#clusterOption="--master yarn --deploy-mode cluster"
runArgs="$SPARKCLR_HOME/scripts/sparkclr-submit.sh $options $clusterOption --exe $ExeName $PWD $@"

echo "------- run test : $runArgs"
bash -c "$runArgs"

#$SPARKCLR_HOME/scripts/sparkclr-submit.sh --master yarn --deploy-mode cluster --jars $SPARKCLR_HOME/dependencies/spark-streaming-kafka-assembly_2.10-1.6.1.jar --exe kafkaStreamTest.exe $PWD -d 1 -r 30 -Topics test -Br 192.168.56.1:9092 -Z 192.168.56.1:2181 2>&1 | lzmw -ie "args.\d+|exception|logger|weak\w*"
