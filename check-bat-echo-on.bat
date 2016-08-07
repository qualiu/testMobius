@SetLocal & @where lzmw.exe >nul 2>nul || if exist "%~dp0tools\lzmw.exe" set "PATH=%PATH%;%~dp0tools"
@lzmw -f "\.bat$" -rp %CD% -it "^\s*(?<ECHO>@?echo)\s+on\b|^\s*(rem\s+|::\s*)(?<ECHO>@?\s*echo)\s+off\b" -N 30
@if %ERRORLEVEL% LSS 1 exit /b 0
@echo.
@echo to replace use following command:
@echo lzmw -f "\.bat$" -it "^\s*(?<ECHO>@?echo)\s+on\b|^\s*(rem\s+|::\s*)(?<ECHO>@?\s*echo)\s+off\b" -o "${1}${3} off" -rp %CD% -N 30 -R
::@echo lzmw -f "\.bat$" -it "^\s*(@?echo)\s+on\b" -o "$1 off" -rp %CD% -N 30 -R
@echo.
