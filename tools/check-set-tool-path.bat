set CommonToolDir=%~dp0
if %CommonToolDir:~-1%==\ set CommonToolDir=%CommonToolDir:~0,-1%
if not exist [%MobiusCodeRoot%] if exist %CommonToolDir%\..\..\csharp\SparkCLR.sln set MobiusCodeRoot=%CommonToolDir%\..\..
rem pushd %MobiusCodeRoot% && set MobiusCodeRoot=!CD! && popd
where psall.bat >nul 2>nul || if exist %CommonToolDir%\psall.bat set "PATH=%PATH%;%CommonToolDir%"
where lzmw.exe >nul 2>nul || if exist "%~dp0lzmw.exe" set "PATH=%PATH%;%~dp0"
where in-later.exe >nul 2>nul || if exist %CommonToolDir%\in-later set "PATH=%PATH%;%CommonToolDir%\in-later"
where lzmw.exe >nul 2>nul || (echo Not found lzmw.exe in %~dp0 , exit %0 && exit /b 1)
