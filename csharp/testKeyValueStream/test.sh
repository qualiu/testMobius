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
TestExePath=$(find $ShellDir -type f -name testKeyValueStream.exe | egrep -v vshost | xargs ls -crt | tail -n 1)

CheckExist "$TestExePath" "test stream exe"

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "No parameter, Usage as following, run : $TestExePath"
    $TestExePath
    echo "Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -n 50 -c /tmp/checkDir -d 1 "
    echo "Test usage just run : $TestExePath"
    exit 
fi

ExeDir=$(dirname $TestExePath)
ExeName=$(basename $TestExePath)

cd $ExeDir
options="--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g"
RunStandalone="$SPARKCLR_HOME/scripts/sparkclr-submit.sh $options --exe $ExeName $PWD $@"
RunYarnCluster="$SPARKCLR_HOME/scripts/sparkclr-submit.sh $options --master yarn --deploy-mode cluster --exe $ExeName $PWD $@"

runArgs=$RunStandalone
echo "------- run test : $runArgs"
bash -c "$runArgs"


