@echo Will set %%MobiusCodeRoot%%=%1 (current=%MobiusCodeRoot%) (root directory of source code that cloned from Mobius github) and update the settings in project files.
@if "%~1" == "" (
	echo Usage   : %0  MobiusCodeRoot
	echo Example : %0  D:\msgit\lqmMobius
	exit /b 5
)

@set MobiusCodeRoot=%1
@for %%a in ("%MobiusCodeRoot%") do set "MobiusCodeRoot=%%~dpa%%~nxa"
@call %~dp0\..\tools\set-common-dir-and-tools.bat
@call %CommonToolDir%\bat\check-exist-path.bat %MobiusCodeRoot% MobiusCodeRoot || exit /b 1

@SetLocal EnableDelayedExpansion
@set MobiusCodeRootReplace=%MobiusCodeRoot:\=\\%


@set /a replacedCount=0

:: for /F "tokens=*" %f in ('lzmw -f "\.csproj$|^allSubmitingTest.sln$" -rp %~dp0 -l -PAC') do @git checkout %f
:: lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "\w+mobius"
:: lzmw -p %~dp0\allSubmitingTest.sln -it "[%%\$\(]+MobiusCodeRoot[%%\)]" -o %MobiusCodeRootReplace% -R

lzmw -p %~dp0\allSubmitingTest.sln -it "(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)" -o "%MobiusCodeRootReplace%" -R -c
@echo. & @set /a replacedCount+=%ERRORLEVEL%

lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "[^<>]*(</MobiusCodeRoot>)" -o "%MobiusCodeRootReplace%${1}" -R -c
@echo. & @set /a replacedCount+=%ERRORLEVEL%

lzmw -rp %~dp0 -f "\.csproj$" -it "(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)" -o "$(MobiusCodeRoot)" -R -c
@echo. & @set /a replacedCount+=%ERRORLEVEL%

if %replacedCount% GTR 0 lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "%%MobiusCodeRoot%%|\$\(MobiusCodeRoot\)|[^<>]*(</MobiusCodeRoot>)|(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)" -e "^<MobiusCodeRoot\s*\w*"
@echo.
