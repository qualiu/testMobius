@echo off
SetLocal EnableDelayedExpansion
if "%~1" == "" (
    echo Usage   : $0  Directory-or-File                                 [lzmw options : like -r to recursive subdirecotry ; -R to replace]
    echo Example : $0  d:\testMobius\testKeyValueStream\bin\Debug        : preview replaced result as no -R; Skip subdirecotry as no -r
    echo Example : $0  d:\testMobius\testKeyValueStream           -R -r  : will Replace recursively
    echo WARNING : #### Only for one line comment : ^<^^!-- xxxxx --^>  and Only deal with : App.config , *.exe.config
    exit /b 5
)

set InputDir=%1
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat
call %CommonToolDir%\bat\check-exist-path.bat %InputDir% || exit /b 1

lzmw -p %InputDir% -f "^App.config$|\.exe\.config$" -it "^^(\s*)<^!-+\s*(<add\s+key\W+(CSharpWorkerPath|CSharpBackendPortNumber)\W+.*?>)\s*-+>" -o "$1$2"  %*
echo. 
