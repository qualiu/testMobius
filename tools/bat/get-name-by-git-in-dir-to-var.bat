::Input 2 args : Git-Directory  Out-Variable-Name
set lzTmpName=
for /F "tokens=*" %%a in ('echo %1 ^| lzmw -it ".*?([\w-]+)\s*$" -o "$1" -PAC --nt "[\\\\/](bin|obj|Debug|Release)\s*$" ') do set lzTmpName=%%a
for /F "tokens=*" %%a in ('cd /d %1 ^&^& git branch ^| lzmw -it "^\*\s+(\S+).*" -o "$1" -PAC ') do if not [%lzTmpName%]==[] (set lzTmpName=%lzTmpName%-%%a) else (set lzTmpName=%%a)
for /F "tokens=*" %%a in ('cd /d %1 ^&^& git log --oneline ^| lzmw -it "^(\w+).*" -o "$1" -H 1 -PAC ') do if not [%lzTmpName%]==[] (set lzTmpName=%lzTmpName%-%%a) else (set lzTmpName=%%a)
set %2=%lzTmpName%