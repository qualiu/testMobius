@SetLocal & @where lzmw.exe >nul 2>nul || if exist "%~dp0tools\lzmw.exe" set "PATH=%PATH%;%~dp0tools"
for /f "tokens=*" %%f in ('lzmw -l -f "\.bat$|^(Build.cmd|Clean.cmd)$" -PAC -rp %CD% --nd apps ') do @unix2dos %%f
