@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

call %CommonToolDir%\bat\find-MobiusTestExePath-in.bat %MobiusTestRoot%\csharp\testKeyValueStream
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestExePath% MobiusTestExePath || exit /b 1
call %MobiusTestRoot%\scripts\tool\warn-dll-exe-x64-x86.bat %MobiusTestExeDir%

set SocketCodeDir=%MobiusTestRoot%\csharp\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir% %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g
call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% SourceSocketExe || exit /b 1
for %%a in ( %SourceSocketExe% ) do set "SourceSocketExeName=%%~nxa"

if not defined SparkOptions set SparkOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G --conf spark.mobius.CSharp.socketType=Rio

if [%1]==[] ( set "TestTimes=1" ) else ( set "TestTimes=%1" )
if [%2]==[] ( set "TestPort=9278" ) else ( set "TestPort=%2" )
if [%3]==[] ( set "EachTestRunSeconds=30" ) else ( set "EachTestRunSeconds=%3" )
if [%4]==[] ( set "ElementCountInArray=10240" ) else ( set "ElementCountInArray=%4" )
if [%5]==[] ( set "SendInterval=100" ) else ( set "SendInterval=%5" )

rem set ElementCountInArray to accelerate memory problem if has
set /a MessagesPerConnection=%EachTestRunSeconds% * 1000 / %SendInterval%
if not defined MobiusTestArgs set MobiusTestArgs=-p %TestPort% -t %TestTimes% -e %ElementCountInArray% -r %EachTestRunSeconds% -w 6 -s 1 -c d:\tmp\testKVCheckDir -d 1
call %CommonToolDir%\bat\show-MobiusVar.bat

if "%~1" == "" (
    echo Usage   : %0   TestTimes [TestPort:9278]  [EachTestRunSeconds:30] [ElementCountInArray:10240] [SendInterval:100]
    echo Example : %0   5          9278             60                       20480                      100
    echo SourceLinesSocket usage : just run %SourceSocketExe%
    echo TestExe usage : just run %MobiusTestExePath%
    rem echo You can set args for %MobiusTestExeName% by set MobiusTestArgs=%MobiusTestArgs% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    rem echo You can set SparkOptions to avoid default. Current SparkOptions=%SparkOptions% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    rem call %CommonToolDir%\bat\show-TestExeVar.bat
    exit /b 5
)

echo Check and stop existed same port socket by pattern "%SourceSocketExeName%.*%TestPort%"
call pskill -it "%SourceSocketExeName%.*%TestPort%" 2>nul
start cmd /c "%SourceSocketExe%" -Port %TestPort% -n %MessagesPerConnection% -s %SendInterval% -RunningSeconds 0 -QuitIfExceededAny 0 -PauseSecondsAtDrop 9 

call %MobiusTestRoot%\csharp\testKeyValueStream\test.bat %MobiusTestArgs% 2>&1 | lzmw -ie "\w*exception|\[(WARN|ERROR|FATAL)\]|warn\w*|spark\w*-submit|[\w\.]*\.(\w*mobius\w*)\.[\w\.]*|\w*RIO\w*" -P

echo Finished test, check and kill SourceLinesSocket and TestExe.
call pskill -it "%SourceSocketExeName%.*%TestPort%|%MobiusTestExeName%.*%TestPort%" 2>nul
call %MobiusTestRoot%\scripts\log\show-local-logs-by-test-exe-dir.bat %MobiusTestExeDir%

