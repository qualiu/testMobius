@echo off
rem input exe path or it's parent/ancestor directory, and out MobiusTestExePath MobiusTestExeDir MobiusTestExeName
if "%~1" == "" (
    echo Should input test exe's parent/ancestor directory! quit %0 
    exit /b 5
)

:: if [%MobiusTestExePath%]==[] for /f %%a in (' for /R %1 %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set MobiusTestExePath=%%a
if [%MobiusTestExePath%] == [] for /f %%a in ('lzmw -rp %1 -f "\.exe$" --nf ".vshost.exe|^CSharpWorker\.exe$" --nd "^obj$" --wt -l -PAC') do set "MobiusTestExePath=%%a"
if not [%MobiusTestExePath%] == [] (
    for %%a in ( %MobiusTestExePath% ) do set "MobiusTestExeDir=%%~dpa"
    if not [!MobiusTestExeDir!] == [] if !MobiusTestExeDir:~-1!==\ set "MobiusTestExeDir=!MobiusTestExeDir:~0,-1!"
    for %%a in ( %MobiusTestExePath% ) do set "MobiusTestExeName=%%~nxa"
)
