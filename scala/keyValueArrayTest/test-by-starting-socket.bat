@echo off
rem local mode test
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

set SocketCodeDir=%ShellDir%\..\..\csharp\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir%  %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g

set MobiusTestJarPath=%ShellDir%\target\KeyValueArrayTestOneJar.jar
if not exist %MobiusTestJarPath% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\find-MobiusTestJarPath-in.bat %MobiusTestJarPath%
call %CommonToolDir%\bat\check-exist-path.bat %MobiusTestJarPath% || exit /b 1
if not defined SparkOptions set SparkOptions=--executor-cores 8 --driver-cores 8 --executor-memory 2G --driver-memory 2G
call %CommonToolDir%\bat\set-SparkOptions-by.bat %SparkOptions%

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following:
    java -jar %MobiusTestJarPath%
    echo Example-1 : -p 9486 -r 30 -b 1 -w 3 -s 3 -v 50 -c checkDir -d 1
    echo Example-2 : -p 9486 -r 30 -b 1 -w 3 -s 3 -v 50 -c checkDir -d 1  2^>^&1 ^| lzmw -it "exception|\b(begin|end).{1,5}test|finished all|used time|args.\d+" -e "\bmemory|\d+\.?\d*\s*[MG]B" -P
    echo Parameters like host, port and validation are according to source socket tool : %SourceSocketExe%
    echo Source socket directory : %SocketCodeDir%
    exit /b 5
)

if "%SPARK_HOME%" == "" (
    call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
    call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1
)

call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1


set Port=9486
set ValidationLines=60
call :ExtractArgs %*

rem use cmd /k if you want to keep the window
start cmd /c "%SourceSocketExe%" -p %Port% -n %ValidationLines% -r 0 -q 0 -z 9

call %SPARK_HOME%\bin\spark-submit.cmd --class lzTest.KeyValueArrayTest %MobiusTestJarPath% %AllArgs%

for %%a in ( %SourceSocketExe% ) do set "SourceSocketExeName=%%~nxa"
call pskill -it "%SourceSocketExeName%.*%Port%|%MobiusTestJarName%.*%Port%" 2>nul

echo ======================================================
echo More source socket usages just run : %SourceSocketExe%
echo Test tool Usage just run : java -jar %MobiusTestJarPath%

exit /b 0

:ExtractArgs
    if "%~1" == ""  goto :End
    if "%1" == "-p" (
        set Port=%2
    )
    if "%1" == "-Port" (
        set Port=%2
    )
    if "%1" == "-v" (
        set ValidationLines=%2
    )
    if "%1" == "ValidateCount" (
        set ValidationLines=%2
    )
    shift
    goto :ExtractArgs
