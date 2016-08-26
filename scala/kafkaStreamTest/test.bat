@echo off
@SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

set MobiusTestJarPath=%ShellDir%\target\KafkaStreamTestOneJar.jar
if not exist %MobiusTestJarPath% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestJarPath% || exit /b 1
call %CommonToolDir%\bat\find-MobiusTestJarPath-in.bat %MobiusTestJarPath%

set KafkaJars=
for /F "tokens=*" %%a in ('lzmw -p %MobiusCodeRoot%\build\dependencies -f "spark-streaming-kafka.+\.jar$" -l -PAC ') do if "!KafkaJars!"=="" ( set "KafkaJars=%%a" ) else ( set "KafkaJars=!KafkaJars!,%%a")

set SparkLocalOptions=--num-executors 8 --executor-cores 8 --executor-memory 2G --driver-memory 2G --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20 --jars %KafkaJars% --conf spark.mobius.streaming.kafka.CSharpReader.enabled=true

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G --conf spark.python.worker.connectionTimeoutMs=3000000 --conf spark.streaming.nao.loadExistingFiles=true --conf spark.streaming.kafka.maxRetries=300 --conf spark.yarn.executor.memoryOverhead=18000 --conf spark.streaming.kafka.maxRetries=20  --conf spark.mobius.streaming.kafka.CSharpReader.enabled=true

call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestJarPath%
    call java -jar %MobiusTestJarPath%
	echo Example-1 : -topic test -w 5 -s 1 -t 1 -d 1
	echo Example-2 : -topic test -w 5 -s 1 -t 1 -d 1  2^>^&1 ^| lzmw -it "exception|\b(begin|end).{1,5}test|finished all|used time|args.\d+" -e "\bmemory|\d+\.?\d*\s*[MG]B" -P
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

call %SPARK_HOME%\bin\spark-submit.cmd %SparkOptions% --class lzTest.KafkaStreamTest %MobiusTestJarPath% %*
