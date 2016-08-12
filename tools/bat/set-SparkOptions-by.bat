@echo off
call %CommonToolDir%\bat\show-MobiusVar.bat
rem set default SparkOptions if not empty %SparkOptions%
echo ##%* | findstr /I /R "[0-9a-z]" >nul || set SparkOptions=%SparkLocalOptions%

call %CommonToolDir%\bat\get-appendix-name-from %SparkOptions%

call %CommonToolDir%\bat\get-name-by-git-in-dir-to-var %MobiusCodeRoot% gitDirBranchCommit

if not "%spark.app.name%" == "" (
    set appNameOption=--name %spark.app.name%
) else (
    if not "%MobiusTestJarName%" == "" set exeJarName=%MobiusTestJarName%
    if not "%MobiusTestExeName%" == "" set exeJarName=%MobiusTestExeName%
    set appNameOption=--name %gitDirBranchCommit%-%MobiusAppHead%!exeJarName!__%AppNameAppendix% %MobiusAppTail%
)

if not "%spark.app.name%" == "" (
    for /F "tokens=*" %%a in ('echo %SparkOptions% ^| lzmw -it "--name\s+(\S+)" -o "" -PAC ') do set SparkOptions=%%a
    call set SparkOptions=!SparkOptions! --name %spark.app.name%
)

echo %SparkOptions% | findstr /I /R "\s*--name[^a-z0-9_-]" >nul || set SparkOptions=%SparkOptions% %appNameOption%
echo Current SparkOptions=%SparkOptions% | lzmw -PA -ie "([\w\.]*\.\w*mobius\w*\.[\w\.]*)|SparkOption\w*|(?:=)\w+|\s+\d+\w{0,2}(\s+|$)"
echo.
