@SetLocal & @where lzmw.exe >nul 2>nul || if exist "%~dp0tools\lzmw.exe" set "PATH=%PATH%;%~dp0tools"
:: git status | lzmw -it "^\s*modified:\s+(../\w+)/.*$" -o "$1" -PAC | not-in-later-uniq nul 2>nul
:: git status | lzmw -it "^\s*(?:modif|delet|new file)\w*\s*:\s+(../[^/]+)/.*$" -o "$1" -PC
:: git status | lzmw -it "^\s*(modif|delet|new file)\w*\s*:\s+(../[^/]+)/.*$" -o "$2" -PC
:: git rm --cached -r %%d
:: git checkout -- %%d
@pushd %~dp0
::for /F "tokens=*" %%d in (' git status ^| lzmw -it "^\s*(?:modif|delet|new file)\w*\s*:\s+(../[^/]+)/.*$" -o "$1" -PAC ^| not-in-later-uniq nul 2^>nul ') do git checkout -- %%d 
@if "%1" == "1" @for /F "tokens=*" %%f in (' git status ^| lzmw -it "^\s*(?:modif|delet|new file)\w*\s*:\s+(../[^/]+.*)$" -o "$1" -PAC ') do git reset %%f
@if not "%1" == "1" for /F "tokens=*" %%f in (' git status ^| lzmw -it "^\s*(?:modif|delet|new file)\w*\s*:\s+(../[^/]+.*)$" -o "$1" -PAC ') do @echo git reset %%f
@popd
