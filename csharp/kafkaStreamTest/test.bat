@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\check-set-tool-path.bat
call %CommonToolDir%\bat\find-TestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %TestExePath% TestExePath || exit /b 1

call %CommonToolDir%\bat\find-jars-in-dir-to-var %MobiusCodeRoot%\build\dependencies JarOption
if not "%JarOption%" == "" set "JarOption=--jars %JarOption%"

set SparkLocalOptions=--executor-cores 2 --driver-cores 2 --executor-memory 2g --driver-memory 2g %JarOption%

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
    echo.
    echo Example-1 : %0 WindowSlideTest -Topics test -d 1 -w 5 -s 1
    echo Example-2 : %0 WindowSlideTest -d 1 -Topics test  2^>^&1 ^| lzmw -it "args.\d+|sumcount|exception"
    exit /b 5
)

if "%~2" == "" (  call %TestExePath% %1 & exit /b 0 )

pushd %TestExeDir%
echo =============== run sparkclr-submit ===================================
echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %TestExeName% %CD% %AllArgs%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %TestExeName% %CD% %AllArgs%
popd

echo ======================================================
echo Test tool usages just run : %TestExePath%
