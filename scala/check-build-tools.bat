@echo off
where mvn 2>nul >nul
if %ERRORLEVEL% EQU 0 exit /b 0

rem check and use maven in MobiusCodeRoot%\build\tools\
for /F "tokens=*" %%d in (' dir /A:D /B %MobiusCodeRoot%\build\tools\apache-maven-* 2^>nul ') do set MavenBuildToolDir=%MobiusCodeRoot%\build\tools\%%d
call :AddToPathWithMavenDir %MavenBuildToolDir% && exit /b 0

set MavenTarVersion=3.3.9
set MavenTarName=apache-maven-%MavenTarVersion%-bin.tar.gz
set MavenInstallDirName=apache-maven-%MavenTarVersion%

rem check and use existed
call %~dp0..\tools\set-common-dir-and-tools.bat
for /F "tokens=*" %%d in (' dir /A:D /B %MobiusTestSoftwareDir%\apache-maven-* 2^>nul ') do set MavenBuildToolDir=%MobiusTestSoftwareDir%\%%d
call :AddToPathWithMavenDir %MavenBuildToolDir% && exit /b 0

rem download maven
if not exist %MobiusTestSoftwareDir%\%MavenTarName% call %DownloadTool% "http://www.us.apache.org/dist/maven/maven-3/%MavenTarVersion%/binaries/%MavenTarName%" %MobiusTestSoftwareDir% %MavenTarName%
call %TarTool% xf %MobiusTestSoftwareDir%\%MavenTarName% -C %MobiusTestSoftwareDir% || exit /b 1
for /F "tokens=*" %%d in (' dir /A:D /B %MobiusTestSoftwareDir%\apache-maven-* 2^>nul ') do set MavenBuildToolDir=%MobiusTestSoftwareDir%\%%d
call :AddToPathWithMavenDir %MavenBuildToolDir% && exit /b 0

where mvn 2>nul >nul || (echo Not found maven in %%PATH%% ! &  exit /b 1)
exit /b 0

:AddToPathWithMavenDir
    if exist "%1\bin" (
        set "PATH=%PATH%;%1\bin"
        exit /b 0
    )
    exit /b 1
