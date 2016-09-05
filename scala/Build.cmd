call %~dp0\check-build-tools.bat || exit /b 1
echo ### Disable following call set-versions-by-Mobius.bat if error.
call %~dp0\set-versions-by-Mobius.bat "%MobiusCodeRoot%" -R
@pushd %~dp0
if exist pom.xml (
    call mvn package
) else (
    for /F %%d in (' dir /A:D /B ') do if exist %%d\pom.xml call mvn package -f %%d\pom.xml
)
@popd
