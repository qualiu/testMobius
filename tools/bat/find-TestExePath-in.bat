rem input parent/ancestor directory, and out TestExePath TestExeDir TestExeName
if [%1] == [] (
    echo Should input test exe's parent/ancestor directory! quit %0 
    exit /b 1
)

if not [%TestJarPath%] == [] (
    for %%a in ( %TestJarPath% ) do ( 
        set TestJarDir=%%~dpa
        set TestJarName=%%~nxa
    )
    if not [!TestJarDir!] == [] if !TestJarDir:~-1!==\ set TestJarDir=!TestJarDir:~0,-1!
)

if [%TestExePath%]==[] for /f %%g in (' for /R %1 %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set TestExePath=%%g
if not [%TestExePath%] == [] (
    for %%a in ( %TestExePath% ) do (
    set TestExeDir=%%~dpa
    set TestExeName=%%~nxa
    )
    if not [!TestExeDir!] == [] if !TestExeDir:~-1!==\ set TestExeDir=!TestExeDir:~0,-1!
 )