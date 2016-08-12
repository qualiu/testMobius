@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%

set SocketCodeDir=%ShellDir%\..\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir% %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g

for /f %%g in (' for /R %ShellDir% %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set MobiusTestExePath=%%g
for %%a in ("%MobiusTestExePath%") do ( 
    set ExeDir=%%~dpa
    set ExeName=%%~nxa
)

set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% "SourceSocketExe" || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd "sparkclr-submit.cmd"  || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %ExeDir% ExeDir || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    echo Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -n 50 -c d:\tmp\checkDir -d 1 
    echo Parameters like host, port and validation are according to source socket tool : %SourceSocketExe%
    echo Test usage just run : %MobiusTestExePath%
    exit /b 5
)

set Port=9333
set LineCount=60
call :ExtractArgs %*

rem use cmd /k if you want to keep the window 
start cmd /c "%SourceSocketExe%" -p %Port% -n %LineCount% -r 999 -q 0 -z 9

set options=--executor-cores 2 --driver-cores 2 --executor-memory 3g --driver-memory 3g
:: SPARK_JAVA_OPTS="-verbose:gc -XX:-UseGCOverheadLimit -XX:+UseCompressedOops -XX:-PrintGCDetails -XX:+PrintGCTimeStamps $SPARK_JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/xujingwen/ocdc/spark-1.4.1-bin-hadoop2.6/`date +%m%d%H%M%S`.hprof"
::set extraJavaOptions=--conf "\"spark.executor.extraJavaOptions=-XX:-UseGCOverheadLimit -Xms2048M -Xmx2048M -verbose:gc -XX:+UseCompressedOops -Xloggc:kvGC.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:ErrorFile=kvError.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=kv-heap-dump.hprof\""
::set extraJavaOptions=--conf "\"spark.executor.extraJavaOptions=-XX:-UseGCOverheadLimit -Xms2048M -Xmx2048M\""

pushd %ExeDir%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %options% %extraJavaOptions% --exe %ExeName% %CD% %AllArgs%
popd

echo ======================================================
echo More source socket usages just run : %SourceSocketExe%
echo Test tool usages just run : %MobiusTestExePath%
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%
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
