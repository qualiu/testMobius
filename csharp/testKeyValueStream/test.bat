@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

set SparkLocalOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G

call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    echo Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -n 50 -c d:\tmp\testKVCheckDir -d 1
    echo Test usage just run : %MobiusTestExePath%
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1

pushd %MobiusTestExeDir%
echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
popd

echo ======================================================
echo Test tool usages just run : %MobiusTestExePath%
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%
