@echo off
rem Submit performance test
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools

set PerfTestExePath=%1
if not "%~2" == "" ( set "PerfRunTimes=%~2" ) else ( set "PerfRunTimes=1" )
if not "%~3" == "" ( set PerfTestData=%3 ) else ( set "PerfTestData=hdfs:///perf/data/deletions/*" )
if not "%~4" == "" ( set PerfTmpDir=%4 ) else ( set "PerfTmpDir=D:\Temp\PerfMobius" )

for /F "tokens=*" %%a in (' hostname ') do set hostname=%%a
if not [%5] == [] ( set LogDir=%5 ) else ( set "LogDir=D:\mobius\perf-logs" )
if not [%6] == [] ( set LogName=%6 ) else ( set "LogName=perf--by-%USERNAME%--on-%hostname%.log" )
set logPath=%LogDir%\%LogName%

set PerfExeName=SparkCLRPerf.exe
if not defined MobiusTestAppHead set MobiusTestAppHead=Run-%PerfRunTimes%
if not defined PerfTestData set PerfTestData=hdfs:///perf/data/deletions/*

call %CommonToolDir%\set-common-dir-and-tools.bat
if not "%PerfTestExePath%" == "" (
    for /f %%a in ('lzmw -rp %PerfTestExePath% -f "%PerfExeName%$" --nf ".vshost.exe|^CSharpWorker\.exe$" --nd "^obj$" --wt -l -PAC') do set "MobiusTestExePath=%%~dpa%%~nxa"    
) else (
   if exist "%MobiusCodeRoot%\csharp\perf" for /f %%a in ('lzmw -rp %MobiusCodeRoot%\csharp\perf -f "%PerfExeName%$" --nf ".vshost.exe|^CSharpWorker\.exe$" --nd "^obj$" --wt -l -PAC') do set "MobiusTestExePath=%%~dpa%%~nxa"    
)

if exist "!MobiusTestExePath!" call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat !MobiusTestExePath!

if not defined EventOptions set EventOptions=--conf spark.eventLog.enabled=true --conf spark.eventLog.dir=hdfs:///perf/eventlog
rem if not defined JarOptions set JarOptions=--jars D:\mobius\perf-lz\dependencies\spark-csv_2.10-1.4.0.jar,D:\mobius\perf-lz\dependencies\commons-csv-1.4.jar
if not defined JarOptions (
    call %CommonToolDir%\bat\find-jars-in-dir-to-var.bat %MobiusCodeRoot%\build\dependencies JarOptions
    set JarOptions=--jars !JarOptions!
)

set SparkLocalOptions=--total-executor-cores 8 --executor-memory 8G %JarOptions%
set SparkClusterOptions=--master yarn-cluster --total-executor-cores 50 --executor-memory 8G %JarOptions% %EventOptions%

if defined SparkOptions (
    call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%
) else (
    call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkClusterOptions%
)

if "%~1" == "" (
    echo Usage   :  %~nx0 PerfTestExePath [PerfRunTimes] [PerfTestData] [PerfTmpDir]  [LogDir]  [LogName] | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-1: %~nx0 %%MobiusCodeRoot%%\csharp\Perf\Microsoft.Spark.CSharp\bin\Release\%PerfExeName%  %PerfRunTimes%  %PerfTestData% %PerfTmpDir%  %LogDir%  %LogName% | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-2: %~nx0 %%MobiusCodeRoot%%\csharp\Perf 3 hdfs:///perf/data/deletions/deletions.csv-00000-of-00020 | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-3: %~nx0 %%MobiusCodeRoot%%\csharp  1  d:\mobius\deletions\deletions.csv-00000-of-00020 %PerfTmpDir%  | lzmw -PA -ie "Usage|Example[-\d]*"
    echo To avoid default, you can set variables of the above and : SparkOptions EventOptions JarOptions | lzmw -PA -ie "Spark\w+|\w*mobius\w+|\w*Option\w*" 
    echo set JustShowCmd=1 will just print the final command and not execute submitting. Current JustShowCmd=%JustShowCmd% | lzmw -PA -ie "(((JustShowCmd)))=\d+|set"
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
    if exist "%PerfTmpDir%" if "%PerfTmpDir%" == "D:\Temp\PerfMobius" (
        echo Remove PerfTmpDir : %PerfTmpDir% | lzmw -PA -t ".*"
        rd /q /s "%PerfTmpDir%"
    )
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1

if not exist %LogDir% md %LogDir%
echo Submit parameters will be saved in %logPath%

set submitArgs=%SparkOptions% --exe %PerfExeName% %MobiusTestExeDir% %PerfTmpDir% %PerfRunTimes% %PerfTestData%
echo.
echo %date% %time% %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %submitArgs% | lzmw -PA -ie "([\w\.]*\.\w*mobius\w*\.[\w\.]*)|SparkOption\w*|(?:=)\w+|\s+\d+\w{0,2}(\s+|$)" -a
echo.

if "%JustShowCmd%" == "1" ( echo Quit as you've set JustShowCmd=%JustShowCmd% & exit /b 0 )

echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %submitArgs% >> %logPath%

pushd %MobiusTestExeDir%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %submitArgs% 2>&1 | lzmw -P -it "\berror\b|exception|cannot|failed" -e "\bwarn|not found" -a
:: call sparkclr-submit.cmd %submitArgs%  2>&1 | lzmw -it "tracking URL|final status" -PC -c -T 2 >> %logPath%
popd 
echo. >> %logPath%
