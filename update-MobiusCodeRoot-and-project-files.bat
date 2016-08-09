@echo off
echo Will set %%MobiusCodeRoot%%=%1 (current=%MobiusCodeRoot%) (root directory of source code that cloned from Mobius github) and update the settings in project files.
if "%~1" == "" (
	echo Usage   : %0  MobiusCodeRoot
	echo Example : %0  D:\msgit\lqmMobius
	exit /b 5
)

set MobiusCodeRoot=%1

SetLocal EnableDelayedExpansion

pushd %~dp0

set MobiusCodeRootReplace=%MobiusCodeRoot:\=\\%
rem %ShellDir%\..\tools\lzmw -p %CD%\csharp\allSubmitingTest.sln -it "[%%\$\(]+MobiusCodeRoot[%%\)]" -o %MobiusCodeRootReplace% -R
tools\lzmw -p %CD%\csharp\allSubmitingTest.sln -it "(?<=\")\S+(?=\\csharp\\\w+\\Microsoft)" -o "%MobiusCodeRootReplace%" -R -c

popd
