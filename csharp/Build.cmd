@echo off
SetLocal EnableDelayedExpansion

echo Usage   : %0  BuildConfig{none^|Debug^|Release} PlatformType(none^|x64^|x86^|Any CPU)  CppDll{none^|NoCpp}
echo Example : %0  Release "Any CPU"
if /I "%~1" == "-h" exit /b 0
if /I "%~1" == "--help" exit /b 0

set BuildConfig=%1
rem if /I "%~2" == "" ( set "PlatformOption=/p:Platform=x64" ) else ( set "PlatformOption=/p:Platform=%~3" )
if /I "%~2" == "" ( set "PlatformOption=" ) else ( set PlatformOption=/p:Platform="%~2" )
if /I "%~3" == "NoCpp" set CppDll=NoCpp

SET ShellDir=%~dp0
@REM Remove trailing backslash \
IF %ShellDir:~-1%==\ SET ShellDir=%ShellDir:~0,-1%
set PROJ_NAME=allSubmitingTest
set PROJ=%ShellDir%\%PROJ_NAME%.sln

if [%MobiusCodeRoot%] == [] (
	echo Warning : not found %%MobiusCodeRoot%% --directory that cloned from Mobius github.
	echo You can set MobiusCodeRoot={MobiusCodeRoot} or just call %ShellDir%\update-MobiusCodeRoot-and-project-files.bat {MobiusCodeRoot}
	echo. 
	set upperTryDir=%ShellDir%\..\..
	if not exist !upperTryDir!\csharp\SparkCLR.sln exit /b -1
	echo Detected and try to set MobiusCodeRoot=!upperTryDir!
	pushd !upperTryDir! && set MobiusCodeRoot=!CD! && popd
)

call %ShellDir%\update-MobiusCodeRoot-and-project-files.bat %MobiusCodeRoot%
echo.

set CppOutDir=%MobiusCodeRoot%\cpp
if not "%CppDll%" == "NoCpp" if exist %CppOutDir% (xcopy /Y /I /S /D %CppOutDir% %ShellDir%\..\cpp >nul ) else (echo Not exist %MobiusCodeRoot%\cpp , Please build first. && exit /b 1)

call %ShellDir%\check-build-tools.bat

@REM Set msbuild location.
SET VisualStudioVersion=14.0
if EXIST "%VS140COMNTOOLS%" SET VisualStudioVersion=14.0

@REM Set Build OS
if not defined CppDll SET CppDll=HasCpp
SET VCBuildTool="%VS120COMNTOOLS:~0,-14%VC\bin\cl.exe"
if EXIST "%VS140COMNTOOLS%" SET VCBuildTool="%VS140COMNTOOLS:~0,-14%VC\bin\cl.exe"
if NOT EXIST %VCBuildTool% SET CppDll=NoCpp


SET MSBUILDEXEDIR=%programfiles(x86)%\MSBuild\%VisualStudioVersion%\Bin
if NOT EXIST "%MSBUILDEXEDIR%\." SET MSBUILDEXEDIR=%programfiles%\MSBuild\%VisualStudioVersion%\Bin
if NOT EXIST "%MSBUILDEXEDIR%\." GOTO :ErrorMSBUILD

SET MSBUILDEXE=%MSBUILDEXEDIR%\MSBuild.exe
SET MSBUILDOPT=/verbosity:minimal /p:WarningLevel=3 %PlatformOption%

if "%builduri%" == "" set builduri=Build.cmd

cd /d "%ShellDir%"

@echo ===== Building %PROJ% =====

@echo Restore NuGet packages ===================
SET STEP=NuGet-Restore

nuget restore "%PROJ%"

@if ERRORLEVEL 1 GOTO :ErrorStop

if "%BuildConfig%" == "" set BuildDebug=1
if not "%BuildConfig%" == "" if /I "%BuildConfig%" == "Debug" set BuildDebug=1
if "%BuildDebug%" == "1" call :BuildByConfig Debug

if "%BuildConfig%" == "" set BuildRelease=1
if not "%BuildConfig%" == "" if /I "%BuildConfig%" == "Release" set BuildRelease=1
if "%BuildRelease%" == "1" call :BuildByConfig Release

if EXIST %PROJ_NAME%.nuspec (
  @echo ===== Build NuGet package for %PROJ% =====
  SET STEP=NuGet-Pack

  powershell -f %ShellDir%\..\build\localmode\nugetpack.ps1
  @if ERRORLEVEL 1 GOTO :ErrorStop
  @echo NuGet package ok for %PROJ%
)

@echo ===== Build succeeded for %PROJ% =====

@GOTO :EOF

:BuildByConfig
	SET Configuration=%1
	@echo ============== Build %Configuration% ============================
	"%MSBUILDEXE%" /p:Configuration=%Configuration%;AllowUnsafeBlocks=true %MSBUILDOPT% "%PROJ%"
	@if ERRORLEVEL 1 GOTO :ErrorStop
	@echo BUILD ok for %Configuration% %PROJ%
	goto :EOF

:ErrorMSBUILD
	set RC=1
	@echo ===== Build FAILED due to missing MSBUILD.EXE. =====
	@echo ===== Mobius requires "Developer Command Prompt for VS2013" and above =====
	exit /B %RC%

:ErrorStop
	set RC=%ERRORLEVEL%
	if "%STEP%" == "" set STEP=%CONFIGURATION%
	@echo ===== Build FAILED for %PROJ% -- %STEP% with error %RC% - CANNOT CONTINUE =====
	exit /B %RC%
	
:EOF
