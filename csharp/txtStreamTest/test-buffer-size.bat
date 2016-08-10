@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools
set CallBat=%ShellDir%\test.bat
call %CommonToolDir%\bat\check-exist-path.bat %CallBat%

if "%~1" == "" (
    echo #################### Usage of %CallBat% ##################################
    call %CallBat%
    echo ############################################################################
    echo.
    echo #################### Usage of this : %0 #####################################
    echo Usage :   csv-data-directory  initial-buffer-size [increase-times: default 1]   [increasement : default : initial-buffer-size] 
    echo Example : D:\csv-2015-10-01   1024                 1
    echo Example : hdfs:///common/AdsData/MUID  1024
    exit /b 5
)

set DataDirectory=%1
set InitBufferSize=%2
set TestTimes=%3
set BufferIncrease=%4

if "%BufferIncrease%" == "" set BufferIncrease=%InitBufferSize%
if "%TestTimes%" == "" set TestTimes=1

if "%MobiusTestExePath%"=="" for /f %%g in (' for /R %ShellDir% %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set MobiusTestExePath=%%g
call %CommonToolDir%\bat\check-exist-path.bat "%MobiusTestExePath%" MobiusTestExePath || exit /b 1

for %%a in ("%MobiusTestExePath%") do ( 
    set ExeDir=%%~dpa
    set ExeName=%%~nxa
)

if %ExeDir:~-1%==\ set ExeDir=%ExeDir:~0,-1%

set configFile=%ExeDir%\CSharpWorker.exe.config
call %CommonToolDir%\bat\check-exist-path.bat %configFile% || exit /b 1
set configBackup=%configFile%-lzbackup
copy /y %configFile% %configBackup%

set bufferSize=%InitBufferSize%
for /L %%k in (1,1, %TestTimes%) do (
    if "%spark.app.name%" == "" set spark.app.name=%ExeName%-buffer-!bufferSize!
    lzmw -p %configFile% -it "(key=\Wspark.mobius.network.buffersize\W\s+value=\W)(\d+)" -o "${1}!bufferSize!" -R
    call %CallBat% %DataDirectory% 
    set /a bufferSize=!bufferSize!+%BufferIncrease%
)

echo Restore configFile : %configFile%
copy /y %configBackup% %configFile%
lzmw -p %configFile% -it "(key=\Wspark.mobius.network.buffersize\W\s+value=\W)(\d+)"
