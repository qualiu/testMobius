@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools

set PerfPythonPath=%1
if not "%~2" == "" ( set "PerfRunTimes=%~2" ) else ( set "PerfRunTimes=1" )
if not "%~3" == "" ( set PerfTestData=%3) else ( set "PerfTestData=hdfs:///perf/data/deletions/*" )

for /F "tokens=*" %%a in (' hostname ') do set hostname=%%a
if not [%5] == [] ( set LogDir=%5 ) else ( set "LogDir=D:\mobius\perf-logs" )
if not [%6] == [] ( set LogName=%6 ) else ( set "LogName=perf--by-%USERNAME%--on-%hostname%.log" )
set logPath=%LogDir%\%LogName%

if not defined MobiusTestAppHead set MobiusTestAppHead=RunPython-%PerfRunTimes%
if not defined PerfTestData set PerfTestData=hdfs:///perf/data/deletions/*

call %CommonToolDir%\set-common-dir-and-tools.bat
if not "%PerfPythonPath%" == "" (
    for /f %%a in ('lzmw -rp %PerfPythonPath% -f "^spark-python-perf.py$" --wt -l -PAC') do set MobiusTestExePath=%%a
) else (
    if not "%MobiusCodeRoot%" == "" (
        for /f %%a in ('lzmw -rp %MobiusCodeRoot% -f "^spark-python-perf.py$" --wt -l -PAC') do set MobiusTestExePath=%%a
    ) else (
        set MobiusTestExePath=%%MobiusCodeRoot%%\python\perf\spark-python-perf.py
    )
)

if exist "%MobiusTestExePath%"  for %%a in (%MobiusTestExePath%) do (
    set MobiusTestExeName=%%~nxa
    set MobiusTestExeDir=%%~dpa
    set MobiusTestExePath=%%~dpa%%~nxa
)

if not defined PyFilesOptions (
    set PyFilesOptions=
    for /F "tokens=*" %%f in (' lzmw -l -f "\.py$" --nf "%MobiusTestExeName%" -p %MobiusTestExeDir% -PAC ') do if "!PyFilesOptions!"=="" ( set "PyFilesOptions=%%f" ) else ( set "PyFilesOptions=!PyFilesOptions!,%%f")
    if not "!PyFilesOptions!" == "" set PyFilesOptions=--py-files !PyFilesOptions!
)

if not defined EventOptions set EventOptions=--conf spark.eventLog.enabled=true --conf spark.eventLog.dir=hdfs:///perf/eventlog
if not defined JarOptions (
    call %CommonToolDir%\bat\find-jars-in-dir-to-var.bat %MobiusCodeRoot%\build\dependencies JarOptions
    set JarOptions=--jars !JarOptions!
)

set SparkLocalOptions=--total-executor-cores 8 --executor-memory 8G %JarOptions%
set SparkClusterOptions=--master yarn-cluster --total-executor-cores 50 --executor-memory 8G  !PyFilesOptions! %JarOptions% %EventOptions% --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=d:/data/anaconda2/python.exe

if defined SparkOptions (
    call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%
) else (
    call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkClusterOptions%
)

if "%~1" == "" (
    echo Usage   : %~nx0 !MobiusTestExePath! [PerfRunTimes] [PerfTestData] [LogDir]  [LogName] | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-1: %~nx0 %MobiusTestExePath%  %PerfRunTimes%  %PerfTestData%   | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-2: %~nx0 %%MobiusCodeRoot%%\python\perf  3  hdfs:///perf/data/deletions/deletions.csv-00000-of-00020 | lzmw -PA -ie "Usage|Example[-\d]*"
    echo Example-3: %~nx0 %%MobiusCodeRoot%%\python\perf  1  d:\mobius\deletions\deletions.csv-00000-of-00020 | lzmw -PA -ie "Usage|Example[-\d]*"
    echo To avoid default, you can set variables of the above and : SparkOptions EventOptions JarOptions | lzmw -PA -ie "Spark\w+|\w*mobius\w+|\w*Option\w*" 
    echo set JustShowCmd=1 will just print the final command and not execute submitting. Current JustShowCmd=%JustShowCmd% | lzmw -PA -ie "(((JustShowCmd)))=\d+|set"
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat !MobiusTestExePath! MobiusTestExePath || exit /b 1

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

if not exist %LogDir% md %LogDir%

echo Submit parameters will be saved in %logPath%
set submitArgs=%SparkOptions% !MobiusTestExePath! %PerfTmpDir% %PerfRunTimes% %PerfTestData%
echo.
echo %date% %time% %SPARK_HOME%\bin\spark-submit.cmd %submitArgs% | lzmw -PA -ie "([\w\.]*\.\w*mobius\w*\.[\w\.]*)|SparkOption\w*|(?:=)\w+|\s+\d+\w{0,2}(\s+|$)" -a
echo.

if "%JustShowCmd%" == "1" ( echo Quit as you've set JustShowCmd=%JustShowCmd% & exit /b 0 )

echo %SPARK_HOME%\bin\spark-submit.cmd %submitArgs% >> %logPath%

pushd %MobiusTestExeDir%
call %SPARK_HOME%\bin\spark-submit.cmd %submitArgs% 2>&1 | lzmw -P -it "\berror\b|exception|cannot|failed" -e "\bwarn|not found" -a
popd
:: call spark-submit.cmd %submitArgs%  2>&1 | lzmw -it "tracking URL|final status" -PC -c -T 2 >> %logPath%
echo. >> %logPath%
