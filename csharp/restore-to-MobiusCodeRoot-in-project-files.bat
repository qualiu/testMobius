@SetLocal EnableDelayedExpansion
@call %~dp0\..\tools\check-set-tool-path.bat > nul
@set /a replacedCount=0
:: for /F "tokens=*" %f in ('lzmw -f "\.csproj$|^allSubmitingTest.sln$" -rp csharp -l -PAC') do @git checkout %f
:: lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "\w+mobius" 

lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "[^<>]*(</MobiusCodeRoot>)" -o "..\\..\\..${1}" -R -c
@echo. & @set /a replacedCount+=%ERRORLEVEL%
lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)" -o "$(MobiusCodeRoot)" -R -c
@echo. & @set /a replacedCount+=%ERRORLEVEL%

:: if %ERRORLEVEL% GTR 0 lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)^s|(?<==)\s*\W*MobiusCodeRoot\W*"  --nt "^\s*^<MobiusCodeRoot^|\s+Condition="
if %ERRORLEVEL% GTR 0 lzmw -rp %~dp0 -f "\.csproj$|^allSubmitingTest.sln$" -it "%%MobiusCodeRoot%%|\$\(MobiusCodeRoot\)|[^<>]*(</MobiusCodeRoot>)|(?<=\")\S+(?=\\csharp\\(?:Adapter^|Worker)\\Microsoft)" -e "^<MobiusCodeRoot\s*\w*"
@echo.
