@echo off
call %CommonToolDir%\bat\show-MobiusVar.bat
rem set default SparkOptions if not empty %SparkOptions%
echo ##%* | findstr /I /R "[0-9a-z]" >nul || set SparkOptions=%SparkLocalOptions%

call %CommonToolDir%\bat\get-appendix-name-from %SparkOptions%

call %CommonToolDir%\bat\get-name-by-git-in-dir-to-var %MobiusCodeRoot% gitDirBranchCommit

if defined MobiusTestAppHead for /F "tokens=*" %%a in ('echo %MobiusTestAppHead% ^| lzmw -t "[^\w\.-]+" -o "" -a -PAC ') do set "MobiusTestAppHead=%%a"
if defined MobiusTestAppTail for /F "tokens=*" %%a in ('echo %MobiusTestAppTail% ^| lzmw -t "[^\w\.-]+" -o "" -a -PAC ') do set "MobiusTestAppTail=%%a"

set appNameOption=
if not "%spark.app.name%" == "" (
    set appNameOption=--name %spark.app.name%
    for /F "tokens=*" %%a in ('echo %SparkOptions% ^| lzmw -it "--name\s+(\S+)" -o "" -PAC ') do set SparkOptions=%%a
    call set SparkOptions=!SparkOptions! --name %spark.app.name%
) else (
    if not "%MobiusTestJarName%" == "" set appNameOption=%MobiusTestJarName%
    if not "%MobiusTestExeName%" == "" set appNameOption=%MobiusTestExeName%
    if not "%gitDirBranchCommit%" == "" set appNameOption=%gitDirBranchCommit%-!appNameOption!
    (echo ##%AppNameBySparkOptions% | findstr /I /R "[0-9a-z]" >nul) && set appNameOption=!appNameOption!__%AppNameBySparkOptions%
    if not "%MobiusTestAppHead%" == "" set appNameOption=%MobiusTestAppHead%-!appNameOption!
    if not "%MobiusTestAppTail%" == "" set appNameOption=!appNameOption!-%MobiusTestAppTail%
    if not "!appNameOption!" == "" set appNameOption=--name !appNameOption!
)

echo %SparkOptions% | findstr /I /R "\s*--name[^a-z0-9_-]" >nul || set SparkOptions=%SparkOptions% %appNameOption%
echo Current SparkOptions=%SparkOptions% | lzmw -PA -ie "([\w\.]*\.\w*mobius\w*\.[\w\.]*)|SparkOption\w*|(?:=)\w+|\s+\d+\w{0,2}(\s+|$)" -t "((--name))\s+(((\S+)))" -a
echo.
