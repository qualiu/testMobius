@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

call %CommonToolDir%\bat\find-TestExePath-in.bat %MobiusTestRoot%\csharp\testKeyValueStream
call %CommonToolDir%\bat\check-exist-path.bat %TestExePath%% TestExePath || exit /b 1

call %MobiusTestRoot%\scripts\tool\warn-dll-exe-x64-x86.bat %TestExeDir%

set SocketCodeDir=%MobiusTestRoot%\csharp\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir% %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g
call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% SourceSocketExe || exit /b 1
for %%a in ( %SourceSocketExe% ) do set SourceSocketExeName=%%~nxa

if not defined SparkOptions set SparkOptions=--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g --conf spark.mobius.CSharp.socketType=Rio

if "%~1" == "" (
    echo Usage   : %0   TestTimes [TestPort:9278]  [EachTestRunSeconds:30] [ElementCountInArray:10240] [SendInterval:100]
    echo Example : %0   5          9278             60                       20480                      100
    echo SourceLinesSocket usage : just run %SourceSocketExe%
    echo TestExe usage : just run %TestExePath%
    echo You can set SparkOptions to avoid default. Current = %SparkOptions%
    exit /b 5
)

set TestTimes=%1
if [%2]==[] ( set TestPort=9278 ) else ( set TestPort=%2 )
if [%3]==[] ( set EachTestRunSeconds=30 ) else ( set EachTestRunSeconds=%3 )
if [%4]==[] ( set ElementCountInArray=10240) else ( set ElementCountInArray=%4 )
if [%5]==[] ( set SendInterval=100 ) else ( set SendInterval=%5 )

rem set ElementCountInArray to accelerate memory problem if has

set /a MessagesPerConnection=%EachTestRunSeconds% * 1000 / %SendInterval%
start cmd /c "%SourceSocketExe%" -Port %TestPort% -n %MessagesPerConnection% -s %SendInterval% -RunningSeconds 0 -QuitIfExceededAny 0 -PauseSecondsAtDrop 9 
call %MobiusTestRoot%\csharp\testKeyValueStream\test.bat -p %TestPort% -t %TestTimes% -e %ElementCountInArray% -r %EachTestRunSeconds% -w 6 -s 1 -c d:\tmp\testKVCheckDir -d 1

echo Finished test, check and kill SourceLinesSocket and TestExe(often already quit)
pskill -it "%SourceSocketExeName%.*%TestPort%|%TestExeName%.*%TestPort%"
