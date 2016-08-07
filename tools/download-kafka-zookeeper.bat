@echo off
rem tar.exe wget.exe from : http://gnuwin32.sourceforge.net/packages.html
rem to fix problems of bat (such as cannot find lable of sub funciton) : unix2dos *.bat

SetLocal EnableExtensions EnableDelayedExpansion

if "%1" == "-h"     set ToShowUsage=1
if "%1" == "--help" set ToShowUsage=1
if "%ToShowUsage%" == "1" (
    echo Usage   : %0  Save-Directory       [OVERWRITE : default = 0 not ]
    echo Example : %0  d:\tmp\               0
    exit /b 0
)

set SAVE_DIR=%1
set OVERWRITE=%2

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%

if "%SAVE_DIR%" == "" set SAVE_DIR=%ShellDir%\apps

rem ======== setttings ========================================
set DataRoot=%ShellDir%\data
set LogRoot=%ShellDir%\logs
for /F "tokens=*" %%d in ('echo %LogRoot%^| lzmw -x \ -o / -PAC ') do set LogRootUnix=%%d
set ZookeeperLogRoot=%LogRoot%\zklog
set KafkaLogRoot=%LogRoot%\kafka-logs
set ZookeeperLogRootUnix=%LogRootUnix%/zklog
set KafkaLogRootUnix=%LogRootUnix%/kafka-logs

set InitTopicDataFile=%ShellDir%\data\init-kafka-data.txt
set TopicName=test
rem ======== setttings ========================================

set TarTool=%ShellDir%\gnu\bsdtar.exe
call %CommonToolDir%\bat\check-exist-path.bat %TarTool% || exit /b 1

set WGetTool=%ShellDir%\wget.exe

set DownloadTool=%ShellDir%\download-file.bat
call %CommonToolDir%\bat\check-exist-path.bat %DownloadTool% || exit /b 1

call icacls %ShellDir%\*.exe /grant Everyone:RX
call icacls %ShellDir%\gnu\*.exe /grant Everyone:RX

set PATH=%PATH%;%ShellDir%

if not exist %SAVE_DIR% md %SAVE_DIR%
if not exist %LogRoot% md %LogRoot%

set KafkaName=kafka_2.10-0.10.0.0
set KafkaTarName=kafka_2.10-0.10.0.0.tgz
rem https://www.apache.org/dist/kafka/0.10.0.0/kafka_2.10-0.10.0.0.tgz
set KafakaUrl="https://www.apache.org/dist/kafka/0.10.0.0/%KafkaTarName%"
set KafkaRoot=%SAVE_DIR%\%KafkaName%
set KafkaBin=bin\windows
set KafkaBinFull=%KafkaRoot%\%KafkaBin%
if not exist "%SAVE_DIR%\%KafkaTarName%" call %DownloadTool% %KafakaUrl% %SAVE_DIR%
if exist %KafkaRoot% (
    if "%OVERWRITE%" == "1"  rd /q /s %KafkaRoot%
) else (
    echo === first time initialize Kafka begin in %0 ==========
    rem %TarTool% xf %SAVE_DIR%\%KafkaTarName% -C %SAVE_DIR%
    pushd %SAVE_DIR% && %TarTool% xf %KafkaTarName% & popd
    call %CommonToolDir%\bat\check-exist-path.bat %KafkaBinFull% || exit /b 1
    lzmw -it "\b(dataDir)\s*=.*$" -o "$1=%ZookeeperLogRootUnix%" -p %KafkaRoot%\config\zookeeper.properties -R
    lzmw -it "\b(log.dirs)\s*=.*$" -o "$1=%KafkaLogRootUnix%" -p %KafkaRoot%\config\server.properties -R
    lzmw -f "\.bat$" -it "^(\s*)#" -o "$1rem"  -rp %KafkaRoot% -R
    if exist %ZookeeperLogRoot% rd /q /s %ZookeeperLogRoot%
    md %ZookeeperLogRoot%
    if exist %KafkaLogRoot% rd /q /s %KafkaLogRoot%
    md %KafkaLogRoot%
    pushd %KafkaRoot%
    rem lzmw -f "\.bat$" -it "^\s*(@?echo\s+)off\b" -o "$1 on" -p "%KafkaBin%" -R -N 9
    start %KafkaBin%\zookeeper-server-start.bat config\zookeeper.properties
    sleep 3
    start %KafkaBin%\kafka-server-start.bat config\server.properties
    sleep 5
    call %ShellDir%\create-test-topic.bat %KafkaBinFull% localhost:2181 localhost:9092 %TopicName% %InitTopicDataFile%
    rem call %KafkaBinFull%\kafka-server-stop.bat
    rem call %KafkaBinFull%\zookeeper-server-stop.bat
    call %ShellDir%\stop-zookeeper-kafka.bat
    echo ====== first time initialize Kafka finished in %0 =========
    popd
)

exit /b 0
    
:DownloadZookeeper
    rem https://www.apache.org/dist/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz
    set ZookeeperName=zookeeper-3.4.8
    set ZookeeperTarName=%ZookeeperName%.tar.gz
    set ZookeeperUrl="ttps://www.apache.org/dist/zookeeper/%ZookeeperName%/%ZookeeperTarName%"
    set ZookeeperRoot=%SAVE_DIR%\%ZookeeperName%
    if not exist %SAVE_DIR%\%ZookeeperTarName% %DownloadTool% %ZookeeperUrl% %SAVE_DIR%
    if exist %ZookeeperRoot% (
        if "%OVERWRITE%" == "1"  rd /q /s %ZookeeperRoot%
    ) else (
        pushd %SAVE_DIR% && %TarTool% xf %ZookeeperTarName% & popd
    )
    
