#!/bin/bash
if [ -z "$YarnLogSaveDir" ]; then
    YarnLogSaveDir="d:\\yarn-logs"
fi

if [ $# -lt 1 ]; then
    shellName=$(basename $0)
    echo "Usage-1  :  $shellName  one-yarn-app-url"
    echo "Example-1:  $shellName  http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0219"
    echo "Usage-2  :  $shellName  tail-id-1 tail-id-2 [url-header : if not set will use YarnAppUrlHeader ]"
    echo "Example-2:  $shellName  219 220 http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0"
    echo "You can set YarnAppUrlHeader (export YarnAppUrlHeader=***) to just input tail-id-1 tail-id-2 *** tail-id-n"
    echo "You can set YarnLogSaveDir to avoid using default"
    exit
fi

if [ -z "$(echo $@ | egrep -ie "[a-z]")" ] && [ -z "$YarnAppUrlHeader" ]; then
    echo "You must export YarnAppUrlHeader=*** at first if just input id"
    exit
fi

function get_one_log_path() {
    appUrl=$1
    appName=$(echo "$appUrl" | awk '{match($0, /.*(application_[0-9a-zA-Z_]+).*/, arr); print arr[1]; }')
    ## echo appUrl=$1 && return ## for debug
    curl "$appUrl" 2>/dev/null | lzmw -it ".*?\b(bn\w+).*logs.*" -o 'robocopy \\\\$1\\data\\yarn\\nm-log-dir\\$appName $YarnLogSaveDir\\$appName--$1 /E /NJH /NJS /NDL /XO' -PAC | lzmw -x '$appName' -o "$appName" -PAC | lzmw -x '$YarnLogSaveDir' -o "$YarnLogSaveDir" -PAC
    #curl "$appUrl" 2>/dev/null | lzmw -it ".*?\b(bn\w+).*logs.*" -o 'robocopy \\\\$1\\data\\yarn\\nm-log-dir\\'"$appName"' d:\\logsBuf\\'"$appName"'--$1 /E' -PAC 
    #curl "$appUrl" 2>/dev/null | lzmw -it ".*?\b(bn\w+).*logs.*" -o 'robocopy \\\\$1\\data\\yarn\\nm-log-dir\\'"$appName"' d:\\logsBuf\\'"$appName--$1"' /E' -PAC 
    #curl "$appUrl" 2>/dev/null | lzmw -it ".*?\b(bn\w+).*logs.*" -o 'robocopy \\\\$1\\data\\yarn\\nm-log-dir\\'"$appName"' d:\\logsBuf /E' -PAC 
}

## get one app time cost : full url or combine with environment variable YarnAppUrlHeader
if [ $# -eq 1 ]; then
    if [ -n "$(echo $1 | egrep -ie '[^0-9]')" ]; then
        get_one_log_path "$1"
    else
        get_one_log_path "$YarnAppUrlHeader$1"
    fi
    exit
fi

## if parameters are 2 id only
if [ $# -eq 2 ] && [ -z "$(echo $@ | egrep -ie '[a-z]')" ]; then
    #for appid in { $1 .. $2 } ; do get_one_log_path $appid; done
    for((id=$1; id<=$2; id++)); do get_one_log_path "$YarnAppUrlHeader$id" ; done
    exit
fi

## if parameters =3 and had YarnAppUrlHeader as last
if [ $# -eq 3 ] && [ -z "$(echo "$1 $2" | egrep -ie '[a-z]')" ] && [ -n "$(echo "$3" | egrep -ie '[a-z]')" ]; then
    get_one_log_path $3$1
    get_one_log_path $3$2
    exit
fi

lastArg=${*: -1:1} # last argument  ${*: -1} # or simply   ${*: -2:1} # next to last

## lastArg is YarnAppUrlHeader
if [ -n "$(echo "$lastArg" | egrep -ie '[a-z]')" ]; then
    for((k=1; k<=$#; k++)); do
        get_one_log_path "$lastArg${@:$k:1}"
    done
    exit
fi

## all are id
for((k=1; k<=$#; k++)); do
    get_one_log_path "$YarnAppUrlHeader${@:$k:1}"
done
