@echo off
SetLocal EnableDelayedExpansion
set ShellDir=%~dp0
if %ShellDir:~-1%==\ set ShellDir=%ShellDir:~0,-1%
set CommonToolDir=%ShellDir%\..\..\tools

set KafkaToolDir=%ShellDir%\..\ReadWriteKafka
rem for /f %%g in (' for /R %KafkaToolDir% %%f in ^(*.exe^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set KafkaToolExe=%%g
for /f %%a in ('lzmw -rp %KafkaToolDir% -f "\.exe$" --nf ".vshost.exe|^CSharpWorker\.exe$" --nd "^obj$" --wt -l -PAC') do set "KafkaToolExe=%%~dpa%%~nxa"

echo KafkaToolExe = %KafkaToolExe%
call %CommonToolDir%\bat\check-exist-path.bat %KafkaToolExe% "kafka tool exe" || exit /b 1

%KafkaToolExe% -IsWrite true -TopicIdUser id_user_1 -TopicIdCount id_count_1 -BrokerList http://localhost:9092 -Interval 0 
%KafkaToolExe% -IsWrite true -TopicIdUser id_user_2 -TopicIdCount id_count_2 -BrokerList http://localhost:9092 -Interval 0
