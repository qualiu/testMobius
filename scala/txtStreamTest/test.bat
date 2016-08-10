@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\check-set-tool-path.bat

set MobiusTestJarPath=%ShellDir%\target\TxtStreamTestOneJar.jar
if not exist %MobiusTestJarPath% (
    pushd %ShellDir% && call mvn package & popd
)

if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestJarPath%
    call java -jar %MobiusTestJarPath%
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestJarPath% || exit /b 1
call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %MobiusTestJarPath%

set SparkLocalOptions=--num-executors 8 --executor-cores 4 --executor-memory 8G --driver-memory 10G --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 --jars %MobiusCodeRoot%\build\dependencies\spark-streaming-kafka-assembly_2.10-1.6.1.jar --conf spark.mobius.streaming.kafka.CSharpReader.enabled=true

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20  --conf spark.mobius.streaming.kafka.CSharpReader.enabled=true

call %CommonToolDir%\bat\set-SparkOptions-by.bat

echo. & echo Current SparkOptions=%SparkOptions% & echo.

if "%SPARK_HOME%" == "" (
    echo Not set SPARK_HOME , treat as local mode
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

call %SPARK_HOME%\bin\spark-submit.cmd %SparkOptions% --class lzTest.TxtStreamTest %MobiusTestJarPath% %*
