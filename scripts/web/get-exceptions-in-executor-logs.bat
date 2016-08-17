@echo off
rem http://gnuwin32.sourceforge.net/packages.html
rem d:\tools\depends22_x64\depends.exe /ot:curl-depends.log c:\cygwin64\bin\curl.exe
rem lzmw -it "^\s{4}\S*.*?(\S+cyg\S+\.dll)$" -p curl-depends.log -o "$1" -PAC| not-in-later-uniq nul
rem for /F "tokens=*" %a in ('lzmw -it "^\s{4}\S*.*?(\S+cyg\S+\.dll)$" -p curl-depends.log -o "$1" -PAC ^| not-in-later-uniq nul ') do copy %a d:\tools\curl-full\

SetLocal EnableDelayedExpansion
if not defined YarnExeSaveDir set YarnExeSaveDir=%CD%
rem Max error log count
if not defined YarnExeStopCount set YarnExeStopCount=3

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
if "%~1" == "" (
    echo Usage :   %0 url
    echo Example : %0 http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/proxy/application_1469835824077_0406/executors/
    echo Example : %0 404         -- get 1 log;  Must already set YarnExeLogHead + YarnExeLogTail | lzmw -PA -e "Yarn\w+"
	echo Example : %0 404 406 393 -- get 3 logs; Must already set YarnExeLogHead + YarnExeLogTail | lzmw -PA -e "Yarn\w+"
    echo Example : %0 404 409 1   -- get 6 logs; Must already set YarnExeLogHead + YarnExeLogTail | lzmw -PA -e "Yarn\w+"
    echo For example: 
	echo You can set YarnExeLogHead=http://yarnresourcemanager2vip.shareddatamobiussvc-dev-bn1.bn1.ap.gbl:81/proxy/application_1469835824077_0  | lzmw -PA -e "Yarn\w+"
    echo you can set YarnExeLogTail=/executors/ alike. | lzmw -PA -e "Yarn\w+"
	echo You can set YarnExeSaveDir or else use YarnExeSaveDir=%CD% | lzmw -PA -e "Yarn\w+"
	echo You can set YarnExeStopCount or else use YarnExeStopCount=%YarnExeStopCount% | lzmw -PA -e "Yarn\w+"
    exit /b 5
)

if not defined UrlTool set UrlTool=read-url.bat

set beginTime=%time%
(echo %* | lzmw -it "[^0-9 ]" -PAC >nul ) && set "IsAllNumber=1"

if "%IsAllNumber%" == "1" (
    if "%YarnExeLogHead%" == "" (echo Please set YarnExeLogHead at first. & exit /b 1)
    if "%~3" == "1" (
        echo ========= Will use %UrlTool% to get successive logs from %1 to %2 | lzmw -PA -ie ".*"
        for /L %%k in (%1, 1, %2) do call :FindOneUrl %YarnExeLogHead%%%k%YarnExeLogTail%
    ) else (
        echo ========= Will use %UrlTool% to get discrete logs specified : %* | lzmw -PA -ie ".*"
        for /F "tokens=*" %%a in ('echo %* ^| lzmw -t "\d+" -o "$0\n" -PAC ^| lzmw -S -t "\s+$" -o "" -PAC') do (
            call :FindOneUrl %YarnExeLogHead%%%a%YarnExeLogTail%
        )
    )
) else (
	call :FindOneUrl "%~1"
)

exit /b 0

:FindOneUrl
    set /a totalLogs=0
    set url="%~1"

    set saveLog=%YarnExeSaveDir%
    for /f "tokens=*" %%a in ('echo %url% ^| lzmw -it ".*?(application\w+).*" -o "$1" -PAC ') do (
        set "saveLog=%YarnExeSaveDir%\%%a-error.log"
    )

    rem curl %url% | lzmw -it ".*(http://.*/std(out|err).start)=[-\d]+.*" -o "$1=0" -P 
    for /F "tokens=*" %%a in ('call %UrlTool% %url% 2^>nul ^| lzmw -it ".*(http://.*/std(out|err).start)=[-\d]+.*" -o "$1=0" -PAC ') do (
        call %UrlTool% "%%a" 2>nul | lzmw -it "\w*exception|RIO.*?(error|fail)|\[(ERROR|FATAL)\]" -U 3 -D 9 -c "%%a" >> "%saveLog%"
        set /a totalLogs+=1
        echo Has read pages[!totalLogs!] : %%a
        echo. >> "%saveLog%"
        lzmw -p "%saveLog%" -it "^matched [1-9]\d*" -l -P >nul
        if !ERRORLEVEL! GEQ %YarnExeStopCount% (
            echo.
            echo Stop as got !ERRORLEVEL! error logs = %YarnExeStopCount% -- YarnExeStopCount , read !totalLogs! urls. | lzmw -PA -it "\d+" -e "Yarn\w+" -a
            goto :EndStatistic
        )
    )

:EndStatistic
    if exist "%saveLog%" call lzmw -p "%saveLog%" -it "^matched [1-9]\d*" -P -l -c
    echo.
    echo Read %totalLogs% executor urls , time from %beginTime% to %time% . Finished url : %url% | lzmw -PA -it "read (\d+)" -e "\d+:\d+:\d+" -a
    echo.
