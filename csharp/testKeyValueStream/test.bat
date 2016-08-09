@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\check-set-tool-path.bat
call %CommonToolDir%\bat\find-TestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %TestExePath% TestExePath || exit /b 1

set SparkLocalOptions=--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G

echo ### You can enable/disable RIO socket by add/remove : --conf spark.mobius.CSharp.socketType=Rio
call %CommonToolDir%\bat\set-SparkOptions-by.bat

echo. & echo Current SparkOptions=%SparkOptions% & echo.

if "%SPARK_HOME%" == "" (
    echo Not set SPARK_HOME , treat as local mode, depends on { %%SPARK_HOME%% + %%HADOOP_HOME%% *** } or just { %%MobiusCodeRoot%% }.
    rem call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %TestExePath%
    call %TestExePath%
    echo Example parameters : -p 9112 -e 1 -r 30 -b 1 -w 3 -s 3 -n 50 -c d:\tmp\testKVCheckDir -d 1
    echo Test usage just run : %TestExePath%
    exit /b 5
)

pushd %TestExeDir%
echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %TestExeName% %CD% %AllArgs%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %TestExeName% %CD% %AllArgs%
popd


echo ======================================================
echo Test tool usages just run : %TestExePath%
