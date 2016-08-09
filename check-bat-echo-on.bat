@SetLocal & @where lzmw.exe >nul 2>nul || if exist "%~dp0tools\lzmw.exe" set "PATH=%PATH%;%~dp0tools"
@lzmw -f "\.bat$" -rp %CD% -it "^\s*(?<ECHO>@?echo)\s+on\b|^\s*(rem\s+|::\s*)(?<ECHO>@?\s*echo)\s+off\b" -N 30
@echo.
@echo easy to turn off : tools\bat\turn-off-bat-debug-in-dir.bat
@echo easy to turn on  : tools\bat\turn-on-bat-debug-in-dir.bat
@if %ERRORLEVEL% LSS 1 exit /b 0
@echo.
@echo or turn off with following command:
@echo lzmw -f "\.bat$" -it "^\s*(?<ECHO>@?echo)\s+on\b|^\s*(rem\s+|::\s*)(?<ECHO>@?\s*echo)\s+off\b" -o "${1}${3} off" -rp %CD% -N 30 -R
::@echo lzmw -f "\.bat$" -it "^\s*(@?echo)\s+on\b" -o "$1 off" -rp %CD% -N 30 -R
@echo.
