call %~dp0\check-build-tools.bat || exit /b 1
@pushd %~dp0
if exist pom.xml (
    call mvn package
) else (
    for /F %%d in (' dir /A:D /B ') do if exist %%d\pom.xml call mvn package -f %%d\pom.xml
)
@popd