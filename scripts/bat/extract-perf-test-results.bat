@echo off
SetLocal EnableDelayedExpansion
if /I "%~1" == "" goto :ShowUsage & exit /b 0
if /I "%~1" == "-h" goto :ShowUsage & exit /b 0
if /I "%~1" == "--help" goto :ShowUsage & exit /b 0

::for /F "tokens=*" %f in ('lzmw -rp D:\mobius\perfBenchLogs -it "Execution time for" -f stdout -l -PAC ^| lzmw -x \ -o / -PAC ') do @lzmw -p %f -it "Execution time for" -PAC | lzmw -it ".*?Execution time for (\w+\S+).*?(Median)\s*=\s*(\d+\s*\w*).*" -o "$1 = $3" -PAC | lzmw -t "\s*[\r\n]\s*" -o "\t" -S -PAC | lzmw -S -t "^.*$" -o "%f\t$0" -PAC | lzmw -it "\S*(application\w+)\S*" -o "$1" -PAC

set PerfLogPath=%1
if [%2]==[] (set "ExtractName=Median") else (set "ExtractName=%2")

for /F "tokens=*" %%f in ('lzmw -rp %PerfLogPath% -it "Execution time for" -f stdout -l -PAC ^| lzmw -x \ -o / -PAC ') do @lzmw -p %%f -it "Execution time for" -PAC | lzmw -it ".*?Execution time for (\w+\S+).*?(%ExtractName%)\s*=\s*(\d+\s*\w*).*" -o "$1 = $3" -PAC | lzmw -t "\s*[\r\n]\s*" -o "\t" -S -PAC | lzmw -S -t "^.*$" -o "%%f\t$0" -PAC | lzmw -it "\S*(application\w+)\S*" -o "$1" -PAC

exit /b 0

:ShowUsage
    echo Usage   : %0  PerfLogPath ExtractName
    echo Example : %0  D:\perflogs Median
    echo ExtractName(Min/Max/Average/Median) ref : https://github.com/Microsoft/Mobius/blob/master/csharp/Perf/Microsoft.Spark.CSharp/Program.cs#L90