rem tar.exe wget.exe from : http://gnuwin32.sourceforge.net/packages.html

SetLocal EnableExtensions EnableDelayedExpansion

if "%1" == "" (
    echo Usage   : %0  Url                                Save-Directory         
    echo Example : %0  http://**/zookeeper-3.4.6.tar.gz   d:\tmp\zookeeper-3.4.6
    exit /b 0
)

set Url=%~1
set SAVE_DIR=%2

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%

set WgetExe=%ShellDir%\gnu\wget.exe

call %CommonToolDir%\bat\check-exist-path.bat %WgetExe% || exit /b 1

if not exist %SAVE_DIR% md %SAVE_DIR%

%WgetExe% --no-check-certificate "%Url%" -P %SAVE_DIR% >nul
