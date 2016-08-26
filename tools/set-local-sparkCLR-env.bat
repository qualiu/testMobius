@echo off
rem set SPARK_HOME HADOOP_HOME SPARKCLR_HOME
@if "%~1" == "" (
    echo Usage   : %0  MOBIUS_CODE_ROOT        [OVERWRITE_ENV : default = 1 overwrite ]
    echo Example : %0  d:\msgit\qualiuMobius    0
    exit /b 5
)

set MOBIUS_CODE_ROOT=%1
rem Change to absolute path/full path if it's relative path
for %%a in ("%MOBIUS_CODE_ROOT%") do set "MOBIUS_CODE_ROOT=%%~dpa%%~nxa"
if %MOBIUS_CODE_ROOT:~-1%==\ set MOBIUS_CODE_ROOT=%MobiusCodeRoot:~0,-1%

set OVERWRITE_ENV=%2
if "%OVERWRITE_ENV%" == "" set "OVERWRITE_ENV=1"

call %~dp0\bat\check-exist-path.bat %MOBIUS_CODE_ROOT%\build\tools "mobius build tools directory" || exit /b 1

for /F "tokens=*" %%d in (' dir /A:D /B %MOBIUS_CODE_ROOT%\build\tools\spark-* 2^>nul ') do set SparkDir=%MOBIUS_CODE_ROOT%\build\tools\%%d

@if [%SparkDir%] == [] (
    echo current %%MobiusCodeRoot%% = %MobiusCodeRoot% , to set = %MOBIUS_CODE_ROOT%
    echo Not found Spark-release in %MOBIUS_CODE_ROOT%\build\tools
    echo Shoud run this at first : %MOBIUS_CODE_ROOT%\build\localmode\RunSamples.cmd
    goto :End
    exit /b 1
)

if "%OVERWRITE_ENV%" == "1" (
    set SPARK_HOME=%SparkDir%
    set HADOOP_HOME=%MOBIUS_CODE_ROOT%\build\tools\winutils
    set SPARKCLR_HOME=%MOBIUS_CODE_ROOT%\build\runtime
) else (
    if not [%SPARK_HOME%] == [] if not exist "%SPARK_HOME%"  set SPARK_HOME=%SparkDir%
    if not [%HADOOP_HOME%] == [] if not exist "%HADOOP_HOME%" set HADOOP_HOME=%MOBIUS_CODE_ROOT%\build\tools\winutils
    if not [%SPARKCLR_HOME%] == [] if not exist "%SPARKCLR_HOME%" set SPARKCLR_HOME=%MOBIUS_CODE_ROOT%\build\runtime
)

if [%SPARK_HOME%] == [] set SPARK_HOME=%SparkDir%
if [%HADOOP_HOME%] == [] set HADOOP_HOME=%MOBIUS_CODE_ROOT%\build\tools\winutils
if [%SPARKCLR_HOME%] == [] set SPARKCLR_HOME=%MOBIUS_CODE_ROOT%\build\runtime

:End
    rem reset temp variables
    set OVERWRITE_ENV=
    set MOBIUS_CODE_ROOT=
    set SparkDir=
