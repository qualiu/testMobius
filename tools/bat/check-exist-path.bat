if "%~1" == "" (echo Not exist %2 : empty path! & exit /b 5)
if exist "%~1" exit /b 0
echo Not exist %2: %1
exit /b 1
