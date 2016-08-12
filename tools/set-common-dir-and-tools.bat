@echo off
rem This script defines common tools path and software save directory.
rem Tools like wget tar ...
set ThisShellDir=%~dp0
if %ThisShellDir:~-1%==\ set ThisShellDir=%ThisShellDir:~0,-1%
set CommonToolDir=%ThisShellDir%

set TarTool=%CommonToolDir%\gnu\bsdtar.exe

rem use DownloadTool if it's enough for your need.
set WgetTool=%CommonToolDir%\gnu\wget.exe
set DownloadTool=%CommonToolDir%\download-file.bat

pushd %CommonToolDir%\..
set MobiusTestSoftwareDir=%CD%\softwares
set MobiusTestDataDir=%CD%\data
set MobiusTestLogDir=%CD%\logs
set MobiusTestRoot=%CD%
where psall.bat 2>nul >nul | set "PATH=%PATH%;%CommonToolDir%;%CommonToolDir%\in-later"
popd

if not exist %MobiusTestSoftwareDir% md %MobiusTestSoftwareDir%
if not exist %MobiusTestDataDir% md %MobiusTestDataDir%
if not exist %MobiusTestLogDir% md %MobiusTestLogDir%

for /F "tokens=*" %%d in (' dir /A:D /B %MobiusTestSoftwareDir%\kafka* 2^>nul ') do set MobiusTestKafkaDir=%MobiusTestSoftwareDir%\%%d
call %CommonToolDir%\check-set-tool-path.bat >nul 2>nul
