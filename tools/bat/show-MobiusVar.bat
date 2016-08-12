@echo off
echo ### Mobius configurations like --conf spark.mobius.CSharp.socketType=Rio follow instruction : https://github.com/Microsoft/Mobius/blob/master/notes/configuration-mobius.md | lzmw -PA -it "([\w\.]*\.\w*((mobius))\w*\.[\w\.]*)" -e "=\w+|(--\w+[-\w]*)|https:\S+"
echo ### set SparkOptions SparkClusterOptions SparkLocalOptions MobiusTestExePath MobiusTestAppHead MobiusTestAppTail to avoid default and auto-detection. | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
if defined SparkClusterOptions (
    echo ### Cluster Mode : set SparkOptions=%SparkClusterOptions% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    echo.
)
if defined SparkLocalOptions (
    echo ### Local Mode : set SparkOptions=%SparkLocalOptions% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    echo.
)
echo ### You can set spark.app.name to avoid default or add MobiusTestAppHead/MobiusTestAppTail. Current: spark.app.name=%spark.app.name%  ; appNameOption=%appNameOption% ; MobiusTestAppHead=%MobiusTestAppHead% ; MobiusTestAppTail=%MobiusTestAppTail%
call %~dp0\show-TestExeVar.bat
if "%SPARK_HOME%" == ""  (
    if "%MobiusCodeRoot%" == "" (
        echo Not set SPARK_HOME , if run in local mode, please set SPARKCLR_HOME + SPARK_HOME + HADOOP_HOME or just MobiusCodeRoot | lzmw -PA -it "(.*)"
    ) else (
        echo If run in local mode and not set SPARKCLR_HOME + SPARK_HOME + HADOOP_HOME, will use MobiusCodeRoot : %MobiusCodeRoot% | lzmw -PA -ie "(.*)"
    )
    echo.
)
