@echo off
rem to fix problems of bat (such as cannot find lable of sub funciton) : unix2dos *.bat
SetLocal EnableExtensions EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%
set PATH=%PATH%;%ShellDir%

if "%~1" == "" (
    echo Usage   : %0  Kafka-Directory          Zookeeper-Port   Kafka-Port  [Zookeeper-Log-Dir]       [Kafka-Log-Dir]
    echo Example : %0  d:\kafka_2.10-0.10.0.0   2181            9092        %ShellDir%\logs\zklogs    %ShellDir%\logs\kafka-logs
    exit /b 5
)

set KAFKA_ROOT=%1
set ZOOKEEPER_PORT=%2
set KAFKA_PORT=%3
set ZOOKEEPER_LOG_ROOT=%4
set KAFKA_LOG_ROOT=%5

for /F "tokens=*" %%d in ('echo %ZOOKEEPER_LOG_ROOT%^| lzmw -x \ -o / -PAC ') do set ZOOKEEPER_LOG_ROOT_Unix=%%d
for /F "tokens=*" %%d in ('echo %KAFKA_LOG_ROOT%^| lzmw -x \ -o / -PAC ') do set KAFKA_LOG_ROOT_Unix=%%d

set KafkaConfig=%KAFKA_ROOT%\config
call %CommonToolDir%\bat\check-exist-path.bat %KafkaConfig% || exit /b 1

call %CommonToolDir%\bat\check-exist-path.bat %ShellDir%\download-common-tools.bat || exit /b 1
call %ShellDir%\download-common-tools.bat

rem Use "-c" to show command, Use "-R" to replace ; No "-R" to preview replacing. No "-o" to see matching. -K" to keep backup. Just run lzmw.exe to get more.
rem set lzmw=lzmw -c -R
set ReplaceTo=-o
set lzmw=lzmw -R

if not "%ZOOKEEPER_PORT%" == "" (
    rem %lzmw% -it "(zookeeper.connect\s*=\s*\S+:)\d+" -o "${1}%ZOOKEEPER_PORT%" -rp %KafkaConfig%
    rem %lzmw% -it "(clientPort\s*=\s*)\d+" -o "${1}%ZOOKEEPER_PORT%" -rp %KafkaConfig%
    %lzmw% -rp %KafkaConfig% -it "(zookeeper.connect\s*=\s*\S+:|clientPort\s*=\s*)\d+" %ReplaceTo% "${1}%ZOOKEEPER_PORT%" 
    echo.
)

if not "%KAFKA_PORT%" == "" (
    rem %lzmw% -rp %KafkaConfig% -it "(listeners\s*=\s*\S+://\S+:)\d+" -o "${1}%KAFKA_PORT%" 
    %lzmw% -rp %KafkaConfig% -it "(bootstrap.servers\s*=\s*\S+\s*:)\d+" %ReplaceTo% "${1}%KAFKA_PORT%" 
    echo.
)

if not [%ZOOKEEPER_LOG_ROOT%] == [] (
    %lzmw% -p %KafkaConfig%\zookeeper.properties -it "\b(dataDir)\s*=.*" %ReplaceTo% "$1=%ZOOKEEPER_LOG_ROOT_Unix%" 
    echo.
)

if not [%KAFKA_LOG_ROOT%] == [] (
    %lzmw% -p %KafkaConfig%\server.properties -it "\b(log.dirs)\s*=.*" %ReplaceTo% "$1=%KAFKA_LOG_ROOT_Unix%" 
    echo.
)
