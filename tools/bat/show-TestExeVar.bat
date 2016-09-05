@echo off
if not "%MobiusTestJarPath%" == "" (
    echo ### You can set MobiusTestExePath to avoid detected: %MobiusTestJarPath% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)|(\S+\.(exe|jar|py))\s*$"
) else (
    echo ### You can set MobiusTestExePath to avoid detected: %MobiusTestExePath% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)|(\S+\.(exe|jar|py))\s*$"
)
if not "%MobiusTestExeName%" == "" (
    if not defined MobiusTestArgs (
        echo ### You can set args for %MobiusTestExeName% by set MobiusTestArgs=xxx | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    ) else (
        echo ### You can set args for %MobiusTestExeName% by set MobiusTestArgs=%MobiusTestArgs% | lzmw -PA -ie "\bset\s+|MobiusTest\w+|SparkOption\w*|(cluster|local)\s*mode|([\w\.]*\.\w*mobius\w*\.[\w\.]*)"
    )
)
