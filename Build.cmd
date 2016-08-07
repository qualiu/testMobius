@setlocal
@set ShellDir=%~dp0
@IF %ShellDir:~-1%==\ SET ShellDir=%ShellDir:~0,-1%

pushd %ShellDir%\csharp && call Build.cmd %* & popd

pushd %ShellDir%\scala && call Build.cmd & popd
