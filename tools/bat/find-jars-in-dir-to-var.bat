@echo off
::Input 2 args : Jar-Directory  Out-Variable-Name
if [%~1] == [] exit /b 1
if not exist %1 exit /b 1
if "%2" == [] ( echo Should provide a variable name to write out for %0 ! & exit /b 5 )
set lzTmpName=
for /F "tokens=*" %%f in (' dir /B %1\*.jar ') do if "!lzTmpName!"=="" ( set "lzTmpName=%1\%%f" ) else ( set "lzTmpName=!lzTmpName!,%1\%%f")
set "%2=%lzTmpName%"
if "%lzTmpName%" == "" exit /b 1 else exit /b 0
