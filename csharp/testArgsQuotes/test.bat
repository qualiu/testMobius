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
call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd "sparkclr-submit.cmd" || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %ExePath% ExePath || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %ExeDir% ExeDir || exit /b 1

set AllArgs=%*
if "%~1" == "" (
    echo No parameter, Usage as following, run : %ExePath%
    call %ExePath%
    exit /b 5
)

pushd %ExeDir%
set options=--executor-cores 2 --driver-cores 2 --executor-memory 1g --driver-memory 1g
call %SPARKCLR_HOME%\scripts\sparkclr-submit.cmd %options% --exe %ExeName% %CD% %AllArgs%
popd
