@echo off
@SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%

set CommonToolDir=%ShellDir%\..\..\tools

set SocketCodeDir=%ShellDir%\..\..\csharp\SourceLinesSocket
for /f %%g in (' for /R %SocketCodeDir%  %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set SourceSocketExe=%%g

set lzJar=%ShellDir%\target\KeyValueArrayTestOneJar.jar
if not exist %lzJar% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\check-exist-path.bat %lzJar% || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following:
    java -jar %lzJar%
    echo Example parameter : -p 9486 -r 30 -b 1 -w 3 -s 3 -v 50 -c d:\tmp\checkDir -d
    echo Parameters like host, port and validation are according to source socket tool : %SourceSocketExe%
    echo Source socket directory : %SocketCodeDir%
    exit /b 5
)

call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SourceSocketExe% || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1


set Port=9486
set ValidationLines=60
call :ExtractArgs %*

rem use cmd /k if you want to keep the window
start cmd /c "%SourceSocketExe%" -p %Port% -n %ValidationLines%

call %SPARK_HOME%\bin\spark-submit.cmd --class lzTest.KeyValueArrayTest %lzJar% %AllArgs%

echo ======================================================
echo More source socket usages just run : %SourceSocketExe%
echo Test tool Usage just run : java -jar %lzJar%

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
