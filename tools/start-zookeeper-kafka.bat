@echo off
rem to fix problems of bat (such as cannot find lable of sub funciton) : unix2dos *.bat
:: lzmw -f "\.bat$" -it "^\s*(@?echo)\s+off\b" -o "$1 on" -N 9 -R -p .
:: lzmw -f "\.bat$" -it "^\s*(@?echo)\s+on\b" -o "$1 off" -N 9 -R -p .
SetLocal EnableExtensions EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%
call %CommonToolDir%\set-common-dir-and-tools.bat

dir /A:D /b %MobiusTestSoftwareDir%\kafka* 2>nul
if %errorlevel% NEQ 0 ( 
    call %ShellDir%\download-kafka-zookeeper.bat %MobiusTestSoftwareDir% || exit /b 1
    sleep 9
)

for /F "tokens=*" %%d in (' dir /A:D /B %MobiusTestSoftwareDir%\kafka* 2^>nul ') do set KafkaRoot=%MobiusTestSoftwareDir%\%%d
call %CommonToolDir%\bat\check-exist-path.bat %KafkaRoot% kafka || exit /b 1

echo ========= start zookeeper and Kafka in %KafkaRoot% ======

pushd %KafkaRoot%
set KafkaBin=%KafkaRoot%\bin\windows
start %KafkaBin%\zookeeper-server-start.bat config\zookeeper.properties
sleep 9
start %KafkaBin%\kafka-server-start.bat config\server.properties
popd
