@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
call %~dp0..\tools\set-common-dir-and-tools.bat

set mobiusRoot=%~1
set ReplaceOrPreview=%2

echo MobiusCodeRoot=%MobiusCodeRoot%
if "%mobiusRoot%" == "" if defined MobiusCodeRoot set mobiusRoot=%MobiusCodeRoot%
if "%mobiusRoot%" == "" (
    echo Usage  : %0  MobiusCodeRoot        [ReplaceOrPreview : -R to replace]
    echo Exampe : %0  d:\msgit\lqmMobius    
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat %mobiusRoot% mobiusRoot || exit /b 1
rem Update scala version
for /F "tokens=*" %%a in ('lzmw -p %mobiusRoot%\scala\pom.xml -it "^\s*<scala.binary.version>\s*(\d+[\.\d]*).*" -o "$1" -PAC ') do set "scalaMajorVersion=%%a"
if not "%scalaMajorVersion%" == "" (
    lzmw -rp %MobiusTestRoot% -f "^pom\.xml$" -it "(<scala.majorVersion>)[^<]*" -o "${1}%scalaMajorVersion%" %ReplaceOrPreview% -c
    echo.
)

for /F "tokens=*" %%a in ('lzmw -p %mobiusRoot%\scala\pom.xml -it "^\s*<scala.version>\s*\d+\.\d+(\.\d+).*" -o "$1" -PAC ') do set "scalaMinorVersion=%%a"
if not "%scalaMinorVersion%" == "" (
    lzmw -rp %MobiusTestRoot% -f "^pom\.xml$" -it "(<scala.minorVersion>)[^<]*" -o "${1}%scalaMinorVersion%" %ReplaceOrPreview% -c
    echo.
)


for /F "tokens=*" %%a in ('lzmw -p %mobiusRoot%\scala\pom.xml -it "^\s*<spark.version>\s*(\d+[\.\d]*).*" -o "$1" -PAC ') do set "sparkVersion=%%a"
if not "%sparkVersion%" == "" (
    lzmw -rp %MobiusTestRoot% -f "^pom\.xml$" -it "(<spark.version>)[^<]*" -o "${1}%sparkVersion%" %ReplaceOrPreview% -c
    echo.
)

for /F "tokens=*" %%a in ('lzmw -p %mobiusRoot%\scala\pom.xml -it "^\s*<spark.version>\s*(\d+\.\d+).*" -o "$1" -PAC ') do set "sparkMajorVersion=%%a"
if not "%sparkMajorVersion%" == "" (
    lzmw -rp %MobiusTestRoot% -f "^pom\.xml$" -it "(<spark.majorVersion>)[^<]*" -o "${1}%sparkMajorVersion%" %ReplaceOrPreview% -c
    echo.
)
