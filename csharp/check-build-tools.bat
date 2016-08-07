call where nuget.exe 2>nul
if %ERRORLEVEL% EQU 0 exit /b 0
if exist "%MobiusCodeRoot%\build\tools\nuget.exe" (
    set "PATH=%PATH%;%MobiusCodeRoot%\build\tools"
	exit /b 0
)

pushd %~dp0..\tools
if not exist nuget.exe call download-file.bat "http://dist.nuget.org/win-x86-commandline/latest/nuget.exe" %CD%
set "PATH=%PATH%;%CD%"
popd
