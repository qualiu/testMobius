@setlocal
@set ShellDir=%~dp0
@IF %ShellDir:~-1%==\ SET ShellDir=%ShellDir:~0,-1%

pushd %ShellDir%\csharp && call Clean.cmd & popd

pushd %ShellDir%\scala && call Clean.cmd & popd
