@echo off
echo You set SparkOptions SparkClusterOptions SparkLocalOptions MobiusTestExePath to avoid default auto-detection.
echo Mobius configuration like --conf spark.mobius.xxx instruction : https://github.com/Microsoft/Mobius/blob/master/notes/configuration-mobius.md | lzmw -PA -ie "https:\S+"
echo ### You can set SparkOptions to avoid default local mode setting. Examples :
echo.
echo ### Cluster Mode : set SparkOptions=%SparkClusterOptions%| lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
echo.
echo ### Local Mode : set SparkOptions=%SparkLocalOptions% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
echo.
echo ### You can set MobiusTestExePath to avoid detected: %MobiusTestExePath% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"

rem set default SparkOptions if not empty %SparkOptions%
echo ##%* | findstr /I /R "[0-9a-z]" >nul || set SparkOptions=%SparkLocalOptions%

call %CommonToolDir%\bat\get-appendix-name-from %SparkOptions%

if not "%spark.app.name%" == "" (
    set appNameOption=--name %spark.app.name%
) else (
    if not "%MobiusTestJarName%" == "" set appNameOption=--name %MobiusTestJarName%__%AppNameAppendix%
    if not "%MobiusTestExeName%" == "" set appNameOption=--name %MobiusTestExeName%__%AppNameAppendix%
)

echo ### You can set spark.app.name to avoid default : spark.app.name = %spark.app.name%  ; appNameOption = %appNameOption%
if not "%spark.app.name%" == "" (
    for /F "tokens=*" %%a in ('echo %SparkOptions% ^| lzmw -it "--name\s+(\S+)" -o "" -PAC ') do set SparkOptions=%%a
    call set SparkOptions=!SparkOptions! --name %spark.app.name%
)

echo %SparkOptions% | findstr /I /R "\s*--name[^a-z0-9_-]" >nul || set SparkOptions=%SparkOptions% %appNameOption%
