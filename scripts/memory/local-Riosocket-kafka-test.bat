@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %MobiusTestRoot%\csharp\kafkaStreamTest
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1

call %MobiusTestRoot%\scripts\tool\warn-dll-exe-x64-x86.bat %MobiusTestExeDir% 

call %CommonToolDir%\bat\find-jars-in-dir-to-var %MobiusCodeRoot%\build\dependencies JarOption
if not "%JarOption%" == "" ( set "JarOption=--jars %JarOption%" ) else ( 
    echo ###### Not found jars in %%MobiusCodeRoot%%\build\dependencies : %MobiusCodeRoot%\build\dependencies , check %%MobiusCodeRoot%% or set JarOption or in SparkOptions | lzmw -PA -it "(.*)"
)

if not defined SparkOptions set SparkOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G %JarOption% --conf spark.mobius.CSharp.socketType=Rio 

if [%1]==[] ( set "TestTimes=1" ) else ( set "TestTimes=%1" )
if [%2]==[] ( set "TopicName=test" ) else ( set "TopicName=%2" )
if [%3]==[] ( set "EachTestRunSeconds=30" ) else ( set "EachTestRunSeconds=%3" )
if [%4]==[] ( set "ElementCountInArray=10240" ) else ( set "ElementCountInArray=%4" )
if [%5]==[] ( set "SendInterval=100" ) else ( set "SendInterval=%5" )

if not defined MobiusTestArgs set MobiusTestArgs=WindowSlideTest -Topics %TopicName% -t %TestTimes% -e %ElementCountInArray% -r %EachTestRunSeconds% -w 6 -s 1 -c d:\tmp\testKafkaKVCheckDir -d 1
call %CommonToolDir%\bat\show-MobiusVar.bat

if "%~1" == "" (
    echo Usage   : %0   TestTimes [TopicName]  [EachTestRunSeconds:30] [ElementCountInArray:10240] [SendInterval:100]
    echo Example : %0   5          test             60                       20480                      100
    echo.
    echo TestExe usage : just run %MobiusTestExePath%
    echo You can set args for %MobiusTestExeName% by set MobiusTestArgs=%MobiusTestArgs% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    echo You can set SparkOptions to avoid default. Current SparkOptions=%SparkOptions% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    exit /b 5
)

set /a KafkaServerCount=0
rem wmic process get ProcessId,Name,CommandLine | lzmw -t "\s+" -o " " -PAC | lzmw --nt "\blzmw\b" -ix "cmd.exe /K %MobiusTestKafkaDir%\bin\windows\kafka-server-start.bat" -P
rem for /F "tokens=*" %%a in (' wmic process get ProcessId^,Name^,CommandLine ^| lzmw -t "\s+" -o " " -PAC ^| lzmw --nt "\blzmw\b" -ix "cmd.exe /K %MobiusTestKafkaDir%\bin\windows\kafka-server-start.bat" -PA') do set /a KafkaServerCount+=1
call psall -it "kafka-server-start.*\s+" -e "kafka\w*"
set KafkaServerCount=%ERRORLEVEL%

if %KafkaServerCount% LSS 1 (
	rem call %MobiusTestRoot%\tools\stop-zookeeper-kafka.bat
	call %MobiusTestRoot%\tools\start-zookeeper-kafka.bat
)

call %MobiusTestRoot%\csharp\kafkaStreamTest\test.bat %MobiusTestArgs% 2>&1 | lzmw -ie "\w*exception|\[(WARN|ERROR|FATAL)\]|warn\w*|spark\w*-submit|[\w\.]*\.(\w*mobius\w*)\.[\w\.]*|\w*RIO\w*" -P
rem pskill -it "%MobiusTestExeName%.*%TopicName%" 2>nul
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%

