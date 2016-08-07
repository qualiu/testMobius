@echo off
SetLocal EnableExtensions EnableDelayedExpansion

if "%1" == "" (
    echo Usage   : %0  KafkaBin                ZookeeperConnection  KafkaBrokerConnection  TopicName  InitTopicDataFile
    echo Example : %0  kafka_2.10\bin\windows  localhost:2181       localhost:9092         test     data\init-kafka-data.txt
    exit /b 0
)

set KafkaBin=%1
set ZookeeperConnection=%2
set KafkaBrokerConnection=%3
set TopicName=%4
set InitTopicDataFile=%5

set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%

call %CommonToolDir%\bat\check-exist-path.bat %KafkaBin% "kafka bin directory" || exit /b 1
call %CommonToolDir%\bat\check-exist-path.bat %KafkaBin%\kafka-topics.bat || exit /b 1

call %KafkaBin%\kafka-topics.bat --create --zookeeper %ZookeeperConnection% --replication-factor 1 --partitions 1 --topic %TopicName%
call %KafkaBin%\kafka-topics.bat --zookeeper %ZookeeperConnection% --list
call %KafkaBin%\kafka-console-producer.bat --broker-list %KafkaBrokerConnection% --topic %TopicName% < %InitTopicDataFile%
call %KafkaBin%\kafka-topics.bat --describe --zookeeper %ZookeeperConnection% --topic %TopicName%
echo for test : %KafkaBin%\kafka-console-consumer --zookeeper %ZookeeperConnection% --from-beginning --topic %TopicName%
