#!/bin/bash
if [ $# -lt 1 ]; then
    shellName=$(basename $0)
    echo "Usage-1  :  $shellName  one-yarn-app-url"
    echo "Example-1:  $shellName  http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0219"
    echo "Usage-2  :  $shellName  tail-id-1 tail-id-2 [url-header : if not set will use YarnAppUrlHeader ]"
    echo "Example-2:  $shellName  219 220 http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/cluster/app/application_1469835824077_0"
    echo "You can set YarnAppUrlHeader (export YarnAppUrlHeader=***) to just input tail-id-1 tail-id-2 *** tail-id-n"
    exit
fi

if [ -z "$(echo $@ | egrep -ie "[a-z]")" ] && [ -z "$YarnAppUrlHeader" ]; then
    echo "You must export YarnAppUrlHeader=*** at first if just input id"
    exit
fi

function get_one_time_cost() {
    appUrl=$1
    ## echo appUrl=$1 && return ## for debug
    curl "$appUrl" 2>/dev/null | lzmw -it "<.*?>" -o " " -a -PAC | lzmw -S -it ":\s*[\r\n]+\s*" -o ":" -PAC \
        | lzmw -it "application|Name\s*:|(yarn|application).*state|elapse" -PAC \
     | awk -v appUrl="$appUrl" 'BEGIN{IGNORECASE=1; cost=0; timeText=""; appId=""; appName=""; state=""; } 
    { 
        if(match($0, /Application\s+(application\w+)/, ta)) appId=ta[1];
        if(match($0, /Name\s*:\s*(\S+)/, ta)) appName=ta[1];
        if(match($0, /State[^:]*:\s*(\w+)/, ta)) state=ta[1];
        if(match($0, /Elapsed\s*:\s*([^\r\n]+)/,  ta)) timeText=ta[1];
    } 
    END {
        if(match(timeText, /([0-9]+)\s*h[ours]*/, ha)) cost+=ha[1]*3600;
        if(match(timeText, /([0-9]+)\s*min/, ma)) cost+=ma[1]*60;
        if(match(timeText, /([0-9]+)\s*sec/, sa)) cost+=sa[1];
        if(ha[1]+ma[1]+sa[1]>0) printf("%s  %s  %ds  %s  %s\n",  appId, state, cost, appName, appUrl);
    }' ;
}

## get one app time cost : full url or combine with environment variable YarnAppUrlHeader
if [ $# -eq 1 ]; then
    if [ -n "$(echo $1 | egrep -ie '[^0-9]')" ]; then
        get_one_time_cost "$1"
    else
        get_one_time_cost "$YarnAppUrlHeader$1"
    fi
    exit
fi

## if parameters are 2 id only
if [ $# -eq 2 ] && [ -z "$(echo $@ | egrep -ie '[a-z]')" ]; then
    #for appid in { $1 .. $2 } ; do get_one_time_cost $appid; done
    for((id=$1; id<=$2; id++)); do get_one_time_cost "$YarnAppUrlHeader$id" ; done
    exit
fi

## if parameters =3 and had YarnAppUrlHeader as last
if [ $# -eq 3 ] && [ -z "$(echo "$1 $2" | egrep -ie '[a-z]')" ] && [ -n "$(echo "$3" | egrep -ie '[a-z]')" ]; then
    get_one_time_cost $3$1
    get_one_time_cost $3$2
    exit
fi

lastArg=${*: -1:1} # last argument  ${*: -1} # or simply   ${*: -2:1} # next to last

## lastArg is YarnAppUrlHeader
if [ -n "$(echo "$lastArg" | egrep -ie '[a-z]')" ]; then
    for((k=1; k<=$#; k++)); do
        get_one_time_cost "$lastArg${@:$k:1}"
    done
    exit
fi

## all are id
for((k=1; k<=$#; k++)); do
    get_one_time_cost "$YarnAppUrlHeader${@:$k:1}"
done
