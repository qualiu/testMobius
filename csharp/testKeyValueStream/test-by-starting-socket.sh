#!/bin/bash
ShellDir=$(cd $(dirname $0) && pwd)
SocketCodeDir=$ShellDir/../SourceLinesSocket
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
SourceSocketExe=$(find $SocketCodeDir -type f -name *.exe | egrep -v vshost | xargs ls -crt | tail -n 1)
TestExePath=$(find $ShellDir -type f -name testKeyValueStream.exe | egrep -v vshost | xargs ls -crt | tail -n 1)

CheckExist "$SourceSocketExe" "Source socket exe"
CheckExist "$TestExePath" "test stream exe"

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "No parameter, Usage as following, run : $TestExePath"
    $TestExePath
    echo "Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -n 50 -c /tmp/checkDir -d 1 "
    echo "Parameters like host, port and validation are according to source socket tool : $SourceSocketExe"
    echo "Test usage just run : $TestExePath"
    exit 
fi

ExeDir=$(dirname $TestExePath)
ExeName=$(basename $TestExePath)

Port=$(echo "$@" | perl -n -e '/(?:\s|^)-P(?:ort)?\s+(\d+)/i && print $1')
Host=$(echo "$@" | perl -n -e '/(?:\s|^)-H(?:ost)?\s+(\S+)/i && print $1')
LineCount=$(echo $@ | perl -n -e '/[^\S]-(?:n|LineCount\w*)(?:ost)?\s+(\d+)/i && print $1')

TestArgs=""
SocketArgs=""

if [ -z "$Port" ]; then
    Port=9789
    TestArgs="-p $Port $TestArgs"
fi

if [ -z "$Host" ]; then
    Host=127.0.0.1
    TestArgs="-H $Host $TestArgs"
fi


SocketArgs="-p $Port $SocketArgs"
SocketArgs="-H $Host $SocketArgs"

if [ -n "$LineCount" ]; then
    SocketArgs="-n $LineCount $SocketArgs"
fi

SocketArgs=$(echo "$SocketArgs" | sed 's/^\s*//' | sed 's/\s*$//' )
#/diskExt/msgit/lz2/test/csharp/SourceLinesSocket/bin/Release/SourceLinesSocket.exe -h 192.168.56.71 -p 9113 -n 60
#cd /diskExt/msgit/lz2/test/csharp/testKeyValueStream/bin/Release
#$SPARKCLR_HOME/scripts/sparkclr-submit.sh --master yarn --deploy-mode cluster --executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g --exe testKeyValueStream.exe $PWD -p 9113 -H 192.168.56.71 -d  1 -c tmp/check-kv-stream -r 30 -b 1 -w 3 -s 3 2>&1 | lzmw -ie "logger|weak\w*|exception"

ExistedSocketPID=$(ps -ef | egrep "$SourceSocketExe $SocketArgs" | grep -v grep | awk '{print $2}')
echo "ExistedSocketPID = $ExistedSocketPID"
if [ -n "$ExistedSocketPID" ]; then
    echo "Kill existed socket pid : $ExistedSocketPID"
    kill $ExistedSocketPID
fi

echo "------- start socket : $SourceSocketExe $SocketArgs"
$SourceSocketExe $SocketArgs &

cd $ExeDir
options="--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g"
RunStandalone="$SPARKCLR_HOME/scripts/sparkclr-submit.sh $options --exe $ExeName $PWD $@ $TestArgs"
RunYarnCluster="$SPARKCLR_HOME/scripts/sparkclr-submit.sh $options --master yarn --deploy-mode cluster --exe $ExeName $PWD $@ $TestArgs"

runArgs=$RunStandalone
echo "------- run test : $runArgs"
bash -c "$runArgs"


