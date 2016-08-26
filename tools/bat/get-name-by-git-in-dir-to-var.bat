@echo off
::Input 2 args : Git-Directory  Out-Variable-Name
if [%~1] == [] exit /b 1
if not exist %1 exit /b 1
if "%2" == [] ( echo Should provide a variable name to write out for %0 ! & exit /b 5 )

set lzTmpName=
:: for /F "tokens=*" %%a in ('echo %1 ^| lzmw -it ".*?([\w-]+)\s*$" -o "$1" -PAC --nt "[\\\\/](bin|obj|Debug|Release)\s*$" ') do set lzTmpName=%%a
for /F "tokens=*" %%a in ('echo %1 ^| lzmw -it ".*?([\w\.-]+)\s*$" -o "$1" -PAC --nt "[\\\\/](bin|obj|Debug|Release)\s*$" ') do set lzTmpName=%%a
for /F "tokens=*" %%a in ('cd /d %1 ^&^& git branch 2^>nul ^| lzmw -it "^\*\s+(\S+).*" -o "$1" -PAC  ') do if not [%lzTmpName%]==[] (set lzTmpName=%lzTmpName%-%%a) else (set lzTmpName=%%a)

:: git log --pretty=format:%h -n 1 ,  git rev-parse --short HEAD, git describe --always
:: git log -1 --oneline 2^>nul ^| lzmw -it "^(\w+).*" -o "$1" -H 1 -PAC
for /F "tokens=*" %%a in ('cd /d %1 ^&^& git rev-parse --short HEAD') do if not [%lzTmpName%]==[] (set lzTmpName=%lzTmpName%-%%a) else (set lzTmpName=%%a)
set %2=%lzTmpName%
