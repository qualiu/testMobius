#!/bin/bash
if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage   : $0  PerfLogPath            ExtractName"
    echo "Example : $0  /cygdrive/d/perflogs   Median"
    echo "ExtractName(Min/Max/Average/Median) ref : https://github.com/Microsoft/Mobius/blob/master/csharp/Perf/Microsoft.Spark.CSharp/Program.cs#L90"
    exit
fi

PerfLogPath=$1
if [ -z "$2" ]; then ExtractName=Median ; else ExtractName=$2 ; fi

## Replace slash for Cygwin : lzmw -x \\ -o / -PAC 
for ff in $(lzmw -rp $PerfLogPath -it "Execution time for" -f stdout -l -PAC | lzmw -x \\ -o / -PAC ); do lzmw -p $ff -it "Execution time for" -PAC | lzmw -it ".*?Execution time for (\w+\S+).*?($ExtractName)\s*=\s*(\d+\s*\w*).*" -o '$1 = $3' -PAC | lzmw -t "\s*[\r\n]\s*" -o "\t" -S -PAC | lzmw -S -t "^.*$" -o '"'$ff'"\t$0' -PAC | lzmw -it "\S*(application\w+)\S*" -o '$1' -PAC; done
