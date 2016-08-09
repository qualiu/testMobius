call where nuget.exe 2>nul
if %ERRORLEVEL% EQU 0 exit /b 0
if exist "%MobiusCodeRoot%\build\tools\nuget.exe" (
    set "PATH=%PATH%;%MobiusCodeRoot%\build\tools"
	exit /b 0
)

call %~dp0..\tools\set-common-dir-and-tools.bat
if not exist nuget.exe call %DownloadTool% "http://dist.nuget.org/win-x86-commandline/latest/nuget.exe" %MobiusTestSoftwareDir% nuget.exe || exit /b 1
set "PATH=%PATH%;%MobiusTestSoftwareDir%"
