@echo off
@SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

set MobiusTestJarPath=%ShellDir%\target\KeyValueArrayTestOneJar.jar
if not exist %MobiusTestJarPath% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\find-MobiusTestJarPath-in.bat %MobiusTestJarPath%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestJarPath% || exit /b 1
if not defined SparkOptions set SparkOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G
call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : java -jar %MobiusTestJarPath%
    java -jar %MobiusTestJarPath%
    echo Example-1 : -p 9486 -r 30 -b 1 -w 3 -s 3 -v 50 -c d:\tmp\checkDir -d 1
    echo Example-2 : -p 9486 -r 30 -b 1 -w 3 -s 3 -v 50 -c d:\tmp\checkDir -d 1   2^>^&1 ^| lzmw -it "exception|\b(begin|end).{1,5}test|finished all|used time|args.\d+" -e "\bmemory|\d+\.?\d*\s*[MG]B" -P
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

call %SPARK_HOME%\bin\spark-submit.cmd --class lzTest.KeyValueArrayTest %MobiusTestJarPath% %AllArgs%

echo ======================================================
echo Test tool Usage just run : java -jar %MobiusTestJarPath%
