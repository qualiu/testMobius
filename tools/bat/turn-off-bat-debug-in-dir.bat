@if "%~1" == "" echo Usage : %0 directory. (recursive add '-r' , replace add '-R'; preview without '-R'. more options see usage of lzmw && exit /b 0
%~dp0..\lzmw -it "^(\s*@\s*echo)\s+on\b" -o "$1 off" -f "\.(bat|cmd)$" -p "%~1" %*
