@echo off
SetLocal EnableExtensions EnableDelayedExpansion

if "%~1" == "" (
	echo Usage   : %0  directory-has-dll-exe-or-in-sub-directory
	echo Example : %0  d:\msgit\testMobius\csharp\testKeyValueStream\bin
	exit /b 5
)

set ToCheckDir=%1

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
call %CommonToolDir%\set-common-dir-and-tools.bat

rem Check x64/x86 compilation result count
echo %MobiusTestRoot%\scripts\tool\check-dll-exe-x64-x86.bat %ToCheckDir% --nd "^(obj|target)$" --nf "log4net|Json|Razorvine|PowerArgs|.vshost.exe"
set /a mpCount=0
for /F "tokens=*" %%a in ('call %MobiusTestRoot%\scripts\tool\check-dll-exe-x64-x86.bat %ToCheckDir% --nd "^(obj|target)$" --nf "log4net|Json|Razorvine|PowerArgs" ^| lzmw -S -it "\s*dumpbin.*?header\S*\s+(.+?\.(exe|dll|lib))\s+.*?[\r\n]+\s*(\S+[^\r\n]*machine[^\r\n]*)" -o "$3 : $1\n" -PAC ^| not-in-later-capture1-uniq nul "machine\s*\(\s*(\w+)\s*\)" 2^>nul ') do (
    set /a mpCount+=1
    echo %%a | lzmw -PA -ie "machine|(x64|x86)|([^\\\\/]+\.\w+)\s*$" --nt "\.bat"
)

if %mpCount% EQU 1 ( echo Checked ok, found only 1 type, example as above. & exit /b 0 )
if %mpCount% EQU 0 ( echo Not found dll/exe/lib in %ToCheckDir% & exit /b 0 )

rem Warn if inconsistent
echo XXXXXX Found %mpCount% types, examples as above, inconsistent XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo.
sleep 1
exit /b 1
