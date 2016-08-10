@echo off
SetLocal EnableDelayedExpansion
if "%~1" == "" (
    echo Usage   : $0  Exe-Path-or-Dir-or-upper-Parent                              [Debug-Port: use 5567 if not set] 
    echo Example : $0  d:\testMobius\testKeyValueStream\bin\Debug\CSharpWorker.exe   5567
    echo Example : $0  d:\testMobius\testKeyValueStream     -- will auto detect exe
    exit /b 5
)

set InputPath=%1
set IputExePath=%1
set DebugPort=%2
set ExePattern=%3
if [%DebugPort%] == [] set DebugPort=5567

echo %DebugPort%| findstr /I /R "[a-z]" && (echo DebugPort must be number but input is '%DebugPort%' & exit /b 1)

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

call %CommonToolDir%\bat\check-exist-path.bat %IputExePath% || exit /b 1

rem echo %IputExePath% | findstr /I /R "\.exe *$" || set IsInputDirectory=0
dir /A:D /B %IputExePath% >nul 2>nul && set "IsInputDirectory=1" || set "IsInputDirectory=0"

::echo IsInputDirectory='%IsInputDirectory%' : %IputExePath%

if "%IsInputDirectory%" == "1" for /F "tokens=*" %%a in ('dir /S /B %IputExePath%\CSharpWorker.exe') do set IputExePath=%%a

for %%a in ( %IputExePath% ) do set "IputExeDir=%%~dpa"
if %IputExeDir:~-1%==\ set IputExeDir=%IputExeDir:~0,-1%
for %%a in ( %IputExePath% ) do set "IputExeName=%%~nxa"

rem echo IputExeDir = '%IputExeDir%' , IputExeName = '%IputExeName%', IputExePath=%IputExeDir%\%IputExeName%
set IputExePathReplace=%IputExePath:\=\\%

set "todoDir=%IputExeDir%"
if "%IsInputDirectory%" == "1" set "todoDir=%InputPath%"

set replacePathArgs=-it "(\"CSharpWorkerPath\"\s+value=\").*(\")" -o "$1%IputExePathReplace%$2" -f "^App.config$|\.exe\.config$"  -R -c
lzmw -rp %todoDir% %replacePathArgs%
echo.

set replacePortArgs=-it "(\"CSharpBackendPortNumber\"\s+value=\").*(\")" -o "${1}%DebugPort%${2}" -f "^App.config$|\.exe\.config$" -R -c
lzmw -rp %todoDir% %replacePortArgs%
echo.

for /F "tokens=*" %%f in ('lzmw -rp %todoDir% -f "^App.config$|\.exe\.config$" --nf "CSharpWorker.exe.config" -PAC -l') do (
    rem if not CSharpBackendPortNumber node, insert appSettings - path - port nodes
    echo.
    lzmw -p %%f -it "CSharpBackendPortNumber|CSharpWorkerPath"
    if !ERRORLEVEL! EQU 0 lzmw -R -p %%f -it "(\s*</configuration>)" -o "\n<appSettings>\n\t<add key=\"CSharpWorkerPath\" value=\"%IputExePathReplace%\"/>\n\t<add key=\"CSharpBackendPortNumber\" value=\"%DebugPort%\"/>\n</appSettings>\n\n${1}"
    echo.
    rem check and turn on commented appSettings
    lzmw -p %%f -it "<appSettings>" -PAC >nul
    echo.
    set /a appSettingsCount=!ERRORLEVEL!
    if !appSettingsCount! EQU 1 (
        lzmw -p %%f -it "<^!--\s*(<appSettings>)" -o "$1" -S -R
        echo.
        lzmw -p %%f -it "(</appSettings>)\s*-->" -o "$1" -S -R
    )
)
echo.
