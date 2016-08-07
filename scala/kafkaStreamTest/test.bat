@echo off
@SetLocal EnableDelayedExpansion

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%

set CommonToolDir=%ShellDir%\..\..\tools

set lzJar=%ShellDir%\target\KafkaStreamTestOneJar.jar
if not exist %lzJar% (
    pushd %ShellDir% && call mvn package & popd
)

call %CommonToolDir%\bat\check-exist-path.bat %lzJar% || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat "%MobiusCodeRoot%" MobiusCodeRoot || exit /b 1
call %CommonToolDir%\set-local-sparkCLR-env.bat %MobiusCodeRoot% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %SPARK_HOME%\bin\spark-submit.cmd || exit /b 1

call %SPARK_HOME%\bin\spark-submit.cmd --class lzTest.KafkaStreamTest %lzJar% %*
