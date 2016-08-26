@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

set MobiusTestJarPath=%ShellDir%\target\TxtStreamTestOneJar.jar
if not exist %MobiusTestJarPath% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestJarPath% || exit /b 1
call %CommonToolDir%\bat\find-MobiusTestJarPath-in.bat %MobiusTestJarPath%

call %CommonToolDir%\bat\find-jars-in-dir-to-var %MobiusCodeRoot%\build\dependencies JarOption
if defined JarOption ( set "JarOption=--jars %JarOption%" ) else ( 
    echo ###### Not found jars in %%MobiusCodeRoot%%\build\dependencies : %MobiusCodeRoot%\build\dependencies , check %%MobiusCodeRoot%% or set JarOption or in SparkOptions | lzmw -PA -it "(.*)"
)

set SparkLocalOptions=--num-executors 8 --executor-cores 8 --executor-memory 8G --driver-memory 8G --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 %JarOption%

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 %JarOption%

call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestJarPath%
    call java -jar %MobiusTestJarPath%
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

call %SPARK_HOME%\bin\spark-submit.cmd %SparkOptions% --class lzTest.TxtStreamTest %MobiusTestJarPath% %*

