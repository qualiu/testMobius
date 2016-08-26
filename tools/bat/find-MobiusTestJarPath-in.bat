@echo off
rem input jar path or it's parent/ancestor directory, and out MobiusTestJarDir and MobiusTestJarName
if "%~1" == "" (
    echo Should input test jar's parent/ancestor directory! quit %0 
    exit /b 5
)

rem for jar must has set MobiusTestJarPath if want to call this script to get MobiusTestJarDir and MobiusTestJarName
if [%MobiusTestJarPath%] == [] for /f %%a in ('lzmw -rp %1 -f "\.jar$" --nd "lib" --wt -l -PAC') do set "MobiusTestJarPath=%%~dpa%%~nxa"
if not [%MobiusTestJarPath%] == [] (
    for %%a in ("%MobiusTestJarPath%") do set "MobiusTestJarDir=%%~dpa"
    for %%a in ("%MobiusTestJarPath%") do set "MobiusTestJarName=%%~nxa"
    if not [!MobiusTestJarDir!] == [] if !MobiusTestJarDir:~-1!==\ set "MobiusTestJarDir=!MobiusTestJarDir:~0,-1!"
    for %%a in ("%MobiusTestJarPath%") do set "MobiusTestJarPath=%%~dpa%%~nxa"
)
