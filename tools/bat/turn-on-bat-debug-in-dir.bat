@if "%~1" == "" echo Usage : %0 directory. (recursive add '-r' , replace add '-R'; preview without '-R'. more options see usage of lzmw && exit /b 0
%~dp0..\lzmw -it "^(\s*@\s*echo)\s+off\b" -o "$1 on" -f "\.(bat|cmd)$" -p "%~1" %* 
