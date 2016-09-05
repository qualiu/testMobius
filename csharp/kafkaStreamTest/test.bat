@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %ShellDir%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

call %CommonToolDir%\bat\find-jars-in-dir-to-var %MobiusCodeRoot%\build\dependencies JarOption
if defined JarOption ( set "JarOption=--jars %JarOption%" ) else ( 
    echo ###### Not found jars in %%MobiusCodeRoot%%\build\dependencies : %MobiusCodeRoot%\build\dependencies , check %%MobiusCodeRoot%% or set JarOption or in SparkOptions | lzmw -PA -it "(.*)"
)

set SparkLocalOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G %JarOption%

set SparkClusterOptions=--master yarn-cluster --num-executors 100 --executor-cores 28 --executor-memory 30G --driver-memory 32G 

call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %MobiusTestExePath%
    call %MobiusTestExePath%
    echo.
    echo Example-1 : %0 WindowSlideTest -Topics test -d 1 -w 5 -s 1 | lzmw -PA -ie "\s+\w+Test"
    echo Example-2 : %0 WindowSlideTest -d 1 -Topics test  2^>^&1  ^| lzmw -it "exception|\b(begin|end).{1,5}test|finished all|used time|args.\d+" -e "\bmemory|\d+\.?\d*\s*[MG]B" -P
    echo Example-3 : %0 UnionTopicTest -Topic1 id_count_1 -Topic2 id_count_2 | lzmw -PA -ie "\s+\w+Test"
    echo You can start Kafka by : %CommonToolDir%\start-zookeeper-kafka.bat  and a topic named 'test' will be created and wrote. | lzmw -PA -it "(?:creat|wr[io]t)\w*" -e "'test'"
    echo You can create topic and write data for test, like : %ShellDir%\create-2-topics-for-test.bat | lzmw -PA -it "\b(?:creat|wr[io]t)\w*\b"
    for /f %%a in ('lzmw -rp %ShellDir%\.. -d ReadWriteKafka -f "\.exe$" --nf ".vshost.exe|^CSharpWorker\.exe$" --nd "^obj$" --wt -l -PAC') do set "KafkaToolExe=%%~dpa%%~nxa"
    if not "!KafkaToolExe!" == "" echo You can read topic data, like : !KafkaToolExe! -ReadTopic id_count_1 | lzmw -PA -ie "\w+\.exe|\bread\b"
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    echo Not set SPARK_HOME , treat as local mode, depends on { %%SPARK_HOME%% + %%HADOOP_HOME%% *** } or just { %%MobiusCodeRoot%% }.
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1


if "%~2" == "" (  call %MobiusTestExePath% %1 & exit /b 0 )

pushd %MobiusTestExeDir%
echo =============== run sparkclr-submit ===================================
echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %SparkOptions% --exe %MobiusTestExeName% %CD% %AllArgs%
popd

echo ======================================================
echo Test tool usages just run : %MobiusTestExePath%
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%
