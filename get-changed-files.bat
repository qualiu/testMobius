:: for /F %f in ('get-changed-files.bat') do git add %f
@SetLocal & where lzmw.exe >nul 2>nul || if exist "%~dp0tools\lzmw.exe" set "PATH=%PATH%;%~dp0tools"
@if not "%1" == "1" git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o "$1" --nt "\(|:\s*$|\s+branch\s+" -PAC | lzmw -t / -o \ -a -PAC
@if "%1" == "1" for /F "tokens=*" %%f in ('git status ^| lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC ^| lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o "$1" --nt "\(|:\s*$|\s+branch\s+" -PAC ^| lzmw -t / -o \ -a -PAC ') do git add %%f
