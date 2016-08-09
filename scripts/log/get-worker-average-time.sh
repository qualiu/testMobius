if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage   : test/tools/shell/get-average-time.sh  log-path           [capture_pattern]                     [replace_to]"
    echo "Example : test/tools/shell/get-average-time.sh  mobius-stream.log  \"^.*func process time: (\d+).*$\"     '\$1' "
    echo "Example : test/tools/shell/get-average-time.sh  mobius-stream.log  \"^.*command process time: (\d+).*$\"  '\$1' "
    exit
fi

log=$1
capture_pattern=$2
replace_to=$3

if [ -n "$(uname -a | egrep -ie cygwin)" ]; then
    cd $(dirname $log)
    log=$(basename $log)
fi

if [ -z "$capture_pattern" ]; then
    capture_pattern="^.*func process time: (\d+).*$"
fi

if [ -z "$replace_to" ]; then
    replace_to='$1'
fi

lzmw -p $log -it "$capture_pattern" -o "$replace_to" -PAC | awk 'BEGIN{sum=0; rows=0} { if($0 > 0) {rows++; sum+=$0;} }  END { printf("rows = %d, average = %f , ", rows, sum/rows); }'
echo "pattern = $capture_pattern"

