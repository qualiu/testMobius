@echo off
rem local mode test 
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

set SocketCodeDir=%ShellDir%\..\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir% %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g

call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% SourceSocketExe || exit /b 1

if not defined SparkOptions set SparkOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G
call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    echo Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 5 -s 1 -n 50 -c d:\tmp\checkDir -d 1   2^>^&1  ^| lzmw -it "exception|\b(begin|end).{1,5}test|finished all|used time|args.\d+" -e "\bmemory|\d+\.?\d*\s*[MG]B" -P
    echo Parameters like host, port and validation are according to source socket tool : %SourceSocketExe%
    echo Test usage just run : %MobiusTestExePath%
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1

set Port=9333
set LineCount=60
call :ExtractArgs %*

rem use cmd /k if you want to keep the window 
start cmd /c "%SourceSocketExe%" -p %Port% -n %LineCount% -r 0 -q 0 -z 9

:: SPARK_JAVA_OPTS="-verbose:gc -XX:-UseGCOverheadLimit -XX:+UseCompressedOops -XX:-PrintGCDetails -XX:+PrintGCTimeStamps $SPARK_JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/xujingwen/ocdc/spark-1.4.1-bin-hadoop2.6/`date +%m%d%H%M%S`.hprof"
::set extraJavaOptions=--conf "\"spark.executor.extraJavaOptions=-XX:-UseGCOverheadLimit -Xms2048M -Xmx2048M -verbose:gc -XX:+UseCompressedOops -Xloggc:kvGC.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:ErrorFile=kvError.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=kv-heap-dump.hprof\""
::set extraJavaOptions=--conf "\"spark.executor.extraJavaOptions=-XX:-UseGCOverheadLimit -Xms2048M -Xmx2048M\""

pushd %MobiusTestExeDir%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% %extraJavaOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
popd

for %%a in ( %SourceSocketExe% ) do set "SourceSocketExeName=%%~nxa"
call pskill -it "%SourceSocketExeName%.*%Port%|%MobiusTestExeName%.*%Port%" 2>nul
echo ======================================================
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%
echo More source socket usages just run : %SourceSocketExe%
echo Test tool usages just run : %MobiusTestExePath%

exit /b 0

:ExtractArgs
    if "%~1" == ""  exit /b 0
    if "%1" == "-p" (
        set Port=%2
    )
    if "%1" == "-Port" (
        set Port=%2
    )
    if "%1" == "-n" (
        set LineCount=%2
    )
    if "%1" == "LineCount" (
        set LineCount=%2
    )
    shift
    goto :ExtractArgs
