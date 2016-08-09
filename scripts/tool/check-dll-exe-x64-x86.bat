@echo off
SetLocal EnableExtensions EnableDelayedExpansion

if "%~1" == "" (
    echo Usage   : %0  directory-or-file                    [lzmw-options except : -f -l -PAC -r -p ]
    echo Example : %0  %%MobiusCodeRoot%%\cpp\x64
    echo Example : %0  D:\msgit\lqmMobius\csharp\Adapter
    echo Example : %0  D:\msgit\lqmMobius\csharp\Adapter   --nd "^(obj|target)$" --nf "log4net|Json|Razorvine"
    exit /b 5
)

set CheckPath=%1

rem call %~dp0..\..\tools\check-set-tool-path.bat
set PATH=%PATH%;%~dp0..\..\tools
where dumpbin 2>nul >nul
if %ERRORLEVEL% GTR 0 (
	for /F "tokens=*" %%a in ('set ^| lzmw -it "(VS\d+com\w*tool\w*)=(.+)" -o "$2" -PAC ') do set VSToolDIR=%%a
	if !VSToolDIR:~-1!==\ set VSToolDIR=!VSToolDIR:~0,-1!
    if exist "!VSToolDIR!\VsDevCmd.bat" ( set "VCEnvBat=!VSToolDIR!\VsDevCmd.bat" ) else ( set "VCEnvBat=!VSToolDIR!\vsvars32.bat" )
    if not exist "!VCEnvBat!" (echo Cannot detect !VCEnvBat! & exit /b 1 )
	rem echo call "!VSToolDIR!\vsvars32.bat" %PlatformBits%
    call "!VSToolDIR!\vsvars32.bat" %PlatformBits%
)

shift
for /F "tokens=*" %%f in ('lzmw -rp %CheckPath% -f "\.(dll|exe|lib)$" -PAC -l %* '); do (
	echo dumpbin /headers %%f ^| lzmw -it "\s+machine\s*\(\s*\w*\d+\w*\s*\)" -PA
	dumpbin /headers %%f | lzmw -it "machine.*\d+" -PA
)
