@echo off
SetLocal EnableExtensions EnableDelayedExpansion

if "%~1" == "" (
    echo Usage   : %0  logFile                                   [save-log-path-or-directory]
    echo Example : %0  application_1471496280077_0052-error.log   d:\tmp
    echo Example : %0  application_1471496280077_0052-error.log   d:\tmp\0052-group-by-pid.log
    exit /b 5
)

set logFile=%~1
set saveLog=%2
set DefaultNamePart=group-by-pid

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

if not exist "%logFile%" (
    echo not exist %logFile%
    exit /b 1
)

set logFileDir=
for %%a in ("%logFile%") do set "logFileDir=%%~dpa"
if %logFileDir:~-1%==\ set "logFileDir=%logFileDir:~0,-1%"

for %%a in ("%logFile%") do set "logFileName=%%~na"
for %%a in ("%logFile%") do set "logFileExtension=%%~xa"

if "!saveLog!" == "" (    
    set saveLog=%logFileDir%\%logFileName%-%DefaultNamePart%%logFileExtension%
) else (
    dir /A:D /B !saveLog! >nul 2>nul && set "isSaveADir=1" || set "isSaveADir=0"
    if "!isSaveADir!" == "1" (
        if !saveLog:~-1!==\ set "saveLog=!saveLog:~0,-1!"
        set saveLog=!saveLog!\%logFileName%-%DefaultNamePart%%logFileExtension%
    )
)

set tmpFile=!saveLog!.tmp
echo saveLog=!saveLog!

rem adjust log begin mess
lzmw -p "%logFile%" -t "^:\d+: " -o "" -PAC -a > %tmpFile%
For /L %%k in (1,1,3) do lzmw -p %tmpFile% -it "^(.+?)(\[\d{1,2}\D\d{1,2}\D\d{1,2}\D{1,2}\d+:\S+\]\s+\[\S+)" -o "$1\n$2" -R -PAC  >nul

rem unify other format time begin such as 16/08/18 23:22:39
lzmw -p %tmpFile% -it "^\s*(\d{1,2}/\d{1,2}/\d{1,2}\D\d+:\d+:\d+[,.]?\d*)" -o "\[$1\]" -R
rem append any line not start with time such as exception/dump to last line
lzmw -S -it "\s*[\r\n]+\s*([^\[\r\n]+)" -o "--NEW-LINE--$1" -p %tmpFile% -R
if exist !saveLog! del !saveLog! 

rem For /F "tokens=*" %%a in ('lzmw -rp %tmpFile% -it "ProcessStream failed with exception" -PAC ^| lzmw -it "^\s*\[\S+\s+\S+\]\s+\[(\d{3,6})\s*\]\s+.*" -o "$1" -PAC ^| not-in-later-uniq nul ') do (
For /F "tokens=*" %%a in ('lzmw -rp %tmpFile% -it "exception" -PAC ^| lzmw -it "^\s*\[\S+\s+\S+\]\s+\[(\d{3,6})\s*\]\s+.*" -o "$1" -PAC ^| not-in-later-uniq nul ') do (
    echo ====== pid--%%a ======= >> !saveLog!
    lzmw -rp %tmpFile% -it "\[%%a\s*\]" -H 9 -T 60 -PAC | lzmw -it "[\r\n\s]*--NEW-LINE--[\r\n\s]*" -o "\n\t" -PAC -a >> !saveLog!  
)

del %tmpFile%

rem add more new-line to each process log begin
lzmw -p !saveLog! -it "^=+.*pid\s*--\d+.*" -o "\n\n$0" -R
rem restore exception stack to multiple lines
lzmw -p !saveLog! -S -it "[\r\n]+\s*(at\s+\w+\.\w+)" -o "\n\t$1" -R
lzmw -p !saveLog! -S -it "(\S*Stack|\w+ stack)\s*=\s*(at\s+)" -o "\n\t$1 = $2" -R
echo.
echo result file = !saveLog! | lzmw -PA -ie "=\s*\S+"
