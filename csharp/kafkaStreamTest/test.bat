@echo off
SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
for /f %%g in (' for /R %ShellDir% %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set ExePath=%%g
for %%a in ("%ExePath%") do ( 
    set ExeDir=%%~dpa
    set ExeName=%%~nxa
)

set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %ExePath% ExePath || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %ExeDir% ExeDir || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %ExePath%
    call %ExePath%
    echo.
    echo Example-1 : %0 WindowSlideTest -Topics test -d 1 -w 5 -s 1
    echo Example-2 : %0 WindowSlideTest -d 1 -Topics test  2^>^&1 ^| lzmw -it "args.\d+|sumcount|exception"
    exit /b 5
)

if "%2" == "" (  call %ExePath% %1 & exit /b 0 )

pushd %ExeDir%

call :FindJarInDir %ShellDir%\lib
call :FindJarInDir %MobiusCodeRoot%\build\dependencies

if not "%JarOption%" == "" (
    set JarOption=--jars %JarOption%
) else (
    echo Not found spark-streaming-kafka-xx.jar , if not in your spark common settings, 
    echo please download it from web, such as : http://repo2.maven.org/maven2/org/apache/spark/spark-streaming-kafka-assembly_2.10/1.6.1/spark-streaming-kafka-assembly_2.10-1.6.1.jar 
    echo and put into %ShellDir%\lib or %MobiusCodeRoot%\build\dependencies
    echo.
    sleep 3
)
echo =============== run sparkclr-submit ===================================
echo %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %options% %JarOption% --exe %ExeName% %CD% %AllArgs%
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %options% %JarOption% --exe %ExeName% %CD% %AllArgs%
popd

echo ======================================================
echo Test tool usages just run : %ExePath%

exit /b 0
    
:FindJarInDir
    if exist %1 (
        for /F "tokens=*" %%f in (' dir /B %1\*.jar ') do set "JarOption=%1\%%f,!JarOption!"
    )
    exit /b 0

