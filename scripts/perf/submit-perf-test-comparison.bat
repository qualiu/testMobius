@echo off
rem Submit and compare new and old performance test on cluster by default.
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
rem call %CommonToolDir%\check-set-tool-path.bat
for /F "tokens=*" %%a in (' hostname ') do set hostname=%%a

if "%~1" == "" (
    echo Usage  :  %0  PerfRunCount SubmitTimes  NewPerfExeDir       OldPerfExeDir            MobiusJarDir           LogDir               LogName
    echo Example : %0  1            1            D:\mobius\new-test  D:\mobius\latest-master  d:\mobius\dependencies D:\mobius\perf-logs  perf--by-%USERNAME%--on-%hostname%.log
    echo To avoid default, you can set variables of the above and : OldPerfAppName NewPerfAppName JarOptions SparkOptions .
    echo Such as :
    echo set OldPerfExeDir=D:\msgit\orgMobius\csharp\Perf\Microsoft.Spark.CSharp\bin\Release
    echo set NewPerfExeDir=D:\msgit\lqmMobius\csharp\Perf\Microsoft.Spark.CSharp\bin\Release
    echo set MobiusJarDir=d:\mobius\perf-lz\dependencies
    echo set OldPerfAppName=org-perf 
    echo set NewPerfAppName=new-perf
    exit /b 5
)

set PerfRunCount=%1
if not [%2] == [] (set "SubmitTimes=%2") else (set "SubmitTimes=1")
if not [%3] == [] set NewPerfExeDir=%3
if not [%4] == [] set OldPerfExeDir=%4
if not [%5] == [] set MobiusJarDir=%5
if not [%6] == [] set LogDir=%6
if not [%7] == [] set LogName=%7

if [%NewPerfExeDir%] == [] set NewPerfExeDir=D:\msgit\lqmMobius\csharp\Perf\Microsoft.Spark.CSharp\bin\Release
if [%OldPerfExeDir%] == [] set OldPerfExeDir=D:\msgit\orgMobius\csharp\Perf\Microsoft.Spark.CSharp\bin\Release
if [%MobiusJarDir%] == [] set MobiusJarDir=d:\mobius\perf-lz\dependencies
if [%LogDir%] == [] set LogDir=D:\mobius\perf-logs
if [%LogName%] == [] set LogName=perf--by-%USERNAME%--on-%hostname%.log

if [%JarOptions%]==[] set JarOptions=--jars %MobiusJarDir%\spark-csv_2.10-1.4.0.jar,%MobiusJarDir%\commons-csv-1.4.jar

set eventOptions=--conf spark.eventLog.enabled=true --conf spark.eventLog.dir=hdfs:///perf/eventlog

set PerfExeName=SparkCLRPerf.exe

call %CommonToolDir%\bat\check-exist-path.bat %OldPerfExeDir%\%PerfExeName% old-perf-exe || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %NewPerfExeDir%\%PerfExeName% new-perf-exe || exit /b 1

set logPath=%LogDir%\%LogName%
if not exist %LogDir% md %LogDir%

rem for /F "tokens=*" %%a in (' lzmw ^| lzmw -it ".*--w1 .([\d-]+ [\d:]+).*" -o "$1" -PAC ^| lzmw -t "\s+" -o "__" -PAC ^| lzmw -it ":" -o "_" -PAC ') do set lzDateTimeNow=%%a
rem for /F "tokens=*" %%a in (' echo %logPath% ^| lzmw -it "[^\\\\/]+\s*$" -o "" -PAC ') do if not exist %%a md %%a

echo Submit parameters will be saved in %logPath%

if [%SparkOptions%] == [] (
    set SparkOptions=--total-executor-cores 30 --executor-memory 8G
    set SparkOptions=--total-executor-cores 100 --executor-memory 30G --driver-memory 32G
    set SparkOptions=--num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G
    set SparkOptions=--num-executors 100 --executor-cores 28 --executor-memory 8G --driver-memory 12G
    set SparkOptions=--master yarn-cluster !SparkOptions! %JarOptions% %eventOptions% 
)

if [%OldPerfAppName%]==[] (
    call %CommonToolDir%\bat\get-name-by-git-in-dir-to-var %OldPerfExeDir% OldPerfAppName
    if not [!OldPerfAppName!]==[] set OldPerfAppName=%PerfExeName%-!OldPerfAppName!
)

if [%NewPerfAppName%]==[] (
    call %CommonToolDir%\bat\get-name-by-git-in-dir-to-var %NewPerfExeDir% NewPerfAppName
    if not [!NewPerfAppName!]==[] set NewPerfAppName=%PerfExeName%-!NewPerfAppName!
)

if [%OldPerfAppName%] == [%NewPerfAppName%] (
    set OldPerfAppName=%PerfExeName%-old
    set NewPerfAppName=%PerfExeName%-new
)

for /L %%k in (1,1,%SubmitTimes%) do (
    call :Submit_Dir_AppName %OldPerfExeDir% %OldPerfAppName%
    echo.
    call :Submit_Dir_AppName %NewPerfExeDir% %NewPerfAppName%
)

exit /b 0

:Submit_Dir_AppName
    set args=D:\Temp\TempDirForSpark %PerfRunCount% hdfs:///perf/data/deletions/*
    set exeDir=%1
    if not "%~2" == "" set appName=%2
    rem Use test exe directory name if not input appName
    if "%~2" == "" for /F "tokens=*" %%a in ('echo %1 ^| lzmw -it ".*?([\w-]+)\s*$" -o "$1" -PAC ') do set appName=%%a
    rem Append args as name tail to be obvious when lookup on cluster web page    
    call %CommonToolDir%\bat\get-appendix-name-from %SparkOptions%
    set submitArgs=--name %appName%-run-%PerfRunCount%__%AppNameAppendix% %SparkOptions% --exe SparkCLRPerf.exe %exeDir% %args%
    echo %date% %time% sparkclr-submit.cmd %submitArgs%
    echo %date% %time% sparkclr-submit.cmd %submitArgs% >> %logPath%
    call sparkclr-submit.cmd %submitArgs%  2>&1 | lzmw -it "tracking URL|final status" -PC -c -T 2 >> %logPath%
    echo. >> %logPath%
    
