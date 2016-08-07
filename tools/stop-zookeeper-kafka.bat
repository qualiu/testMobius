@echo off
rem pskill -it "zookeeper|kafka"

SetLocal EnableExtensions EnableDelayedExpansion
@set ShellDir=%~dp0
@if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
@set PATH=%PATH%;%ShellDir%
echo ==== stop Kafka ===============================
call psall -it kafka.kafka
call pskill -it kafka.kafka

echo ==== stop Zookeeper ===========================
call psall -it zookeeper
call pskill -it "cmd.*kafka-server-start|zookeeper-server-start.bat\s+config|org.apache.zookeeper.server.quorum.QuorumPeerMain"

psall -it "zookeeper|Kafka" -c


