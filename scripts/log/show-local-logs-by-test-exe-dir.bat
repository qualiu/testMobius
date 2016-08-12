@echo off
SetLocal EnableDelayedExpansion

if "%~1" == "" (
    echo Usage :   %0  [exe-directory-has-.exe.config                       [show-log-path-option of lzmw : -T 3 , like -H 3 -T 3 ]
    echo Example : %0 d:\msgit\testMobius\csharp\kafkaStreamTest\bin\Debug
    echo Example : %0 d:\msgit\testMobius\csharp\kafkaStreamTest\bin   -- will recursively find Debug and Release
    exit /b 5
)

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
set InputDir=%1
shift
set ShowPathOption=%*
if "%~1" == "" set ShowPathOption=-T 3

for /F "tokens=*" %%a in ('lzmw -rp %InputDir% -f "\.exe\.config$" -l -PAC ') do (
    rem lzmw -p %%f -it "^.*?env\{(\w+)\}(.*[\\\\/]\w+)[^\\\\/].*$" -o "%%$1%%$2" -PAC | lzmw -x \\ -o \ -PAC -a | lzmw -it "^(.+)[\\\\/](\w+)$" -o "lzmw -rp \"$1\" -d $2 -l --wt -T 2" -PAC
    for /F "tokens=*" %%d in ('lzmw -p %%a -it "^.*?env\{(\w+)\}(.*[\\\\/]\w+)[^\\\\/].*$" -o "%%$1%%$2" -PAC ^| lzmw -x \\ -o \ -PAC -a ^| lzmw -it "^(.+)[\\\\/](\w+)$" -o "\"$1\" -f $2 -l --wt %ShowPathOption% " -PAC') do (
        echo %%~dpa%%~nxa logs as following  : lzmw -rp %%d  | lzmw -PA -it "(\.exe)\.config" -o "$1" -a | lzmw -PA -it "\w+\.exe" -e "Debug|Release|x86|x64"
        call lzmw -rp %%d 2>nul
        echo. & echo.
    )
)
