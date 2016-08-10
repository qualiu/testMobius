@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
set MobiusTestExePath=%ShellDir%\textStreamTest.py

call %CommonToolDir%\check-set-tool-path.bat
call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %ShellDir%

set SparkLocalOptions=--num-executors 8 --executor-cores 4 --executor-memory 8G --driver-memory 10G --conf spark.yarn.executor.memoryOverhead=18000

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=d:/data/anaconda2/python.exe

call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%
echo. & echo Current SparkOptions=%SparkOptions% & echo.

if "%SPARK_HOME%" == "" (
    echo Not set SPARK_HOME , treat as local mode
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
    rem if not "%PythonExe%" == "" for /F "tokens=*" %%f in ('where python.exe 2^>nul ') do set PythonExe=%%f
    rem set "PATH=%PATH%;%SPARK_HOME%\python\pyspark"
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    exit /b 5
)

echo %SPARK_HOME%\bin\spark-submit.cmd %SparkOptions% %MobiusTestExePath% %AllArgs%
call %SPARK_HOME%\bin\spark-submit.cmd %SparkOptions% %MobiusTestExePath% %AllArgs%
