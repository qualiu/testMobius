#!/bin/bash
if [ $# -lt 1 ] || [ "(" = "-h" ] || [ "(" = "--help" ]; then
    echo "Usage   : $0 log-path"
    echo "Example : $0 /d/mobius/spark-streaming.log"
    exit
fi

log=$1

ShellDir=$(cd $(dirname $0) && pwd)
TimeCostTool=$ShellDir/get-average-time.sh

if [ ! -f $TimeCostTool ]; then
    echo "Not exist $TimeCostTool"
    exit
fi

if [ -n "$(uname -a | egrep -ie cygwin)" ]; then
     cd $(dirname $log)
     log=$(basename $log)
fi

$TimeCostTool $log "^.*func process time: (\d+).*$"
$TimeCostTool $log "^.*command process time: (\d+).*$"

oldIFS="$IFS";  IFS=$'\n' times=($(lzmw -p $log -it "^\[(\S+ \S+)\].*RunSimpleWorker.*" -o '$1' -H 1 -T 1 -PAC)) ; IFS=$oldIFS
#for var in "${times[@]}" ; do  echo "${var}" ; done
awk -v s1="${times[0]}" -v s2="${times[1]}" -v t1=$(date +%s.%3N -d "${times[0]}") -v t2=$(date +%s.%3N -d "${times[1]}") 'BEGIN {printf("Workers used time = %f , from %s to %s .\n", t2 - t1, s1, s2);}' 
#lzmw -p $log -it "^\[(\S+ \S+)\].*RunSimpleWorker.*" -o '$1' -H 1 -T 1 -PAC | xargs -I tt date +'%s.%3N' -d tt 2>/dev/null | awk '{times[k++] = $0} END {printf("Workers used time = %f\n", times[k-1] - times[0]); }'
