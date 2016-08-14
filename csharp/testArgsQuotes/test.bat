@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

set SparkLocalOptions=--executor-cores 8 --driver-cores 8 --executor-memory 1G --driver-memory 1G
set SparkClusterOptions=--master yarn-cluster --num-executors 8 --executor-cores 8 --executor-memory 8G --driver-memory 8G
call %CommonToolDir%\bat\set-SparkOptions-by.bat 

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    echo Not set SPARK_HOME , treat as local mode, depends on { %%SPARK_HOME%% + %%HADOOP_HOME%% *** } or just { %%MobiusCodeRoot%% }.
    rem call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1

pushd %MobiusTestExeDir%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
popd
