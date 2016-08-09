@echo off
rem tar.exe wget.exe from : http://gnuwin32.sourceforge.net/packages.html
SetLocal EnableExtensions EnableDelayedExpansion

if "%~1" == "" (
    echo Usage   : %0  Url                                Save-Directory          [SaveName]
    echo Example : %0  http://**/zookeeper-3.4.6.tar.gz   d:\tmp\zookeeper-3.4.6  zookeeper-3.4.6.tar.gz
    echo Define SaveName will safely download to a SaveName.tmp then rename it to SaveName
    exit /b 5
)

set Url=%~1
set SaveDir=%2
set SaveName=%3

if %SaveDir:~-1%==\ set SaveDir=%SaveDir:~0,-1%

call %~dp0\set-common-dir-and-tools.bat
call %CommonToolDir%\bat\check-exist-path.bat %WgetTool% || exit /b 1

if [%SaveDir%] == [] set SaveDir=%MobiusTestSoftwareDir%
if not exist %SaveDir% md %SaveDir%

if [%SaveName%] == [] (
    %WgetTool% --no-check-certificate "%Url%" -P %SaveDir%
) else (
    if exist %SaveDir%\%SaveName%.tmp del /F %SaveDir%\%SaveName%.tmp
    %WgetTool% --no-check-certificate "%Url%" -O %SaveDir%\%SaveName%.tmp
    move %SaveDir%\%SaveName%.tmp %SaveDir%\%SaveName%
)
