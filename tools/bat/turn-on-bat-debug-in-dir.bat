@if "%~1" == "" (
    echo Usage : %0 directory. recursive add '-r' , replace add '-R'; preview without '-R'. more options see usage of %~dp0..\lzmw
    echo Example-preview : %0 %CD%
    echo Example-replace : %0 %CD% -R
    echo Example-preview-sub-directory : %0 %CD% -r
    echo Example-replace-sub-directory : %0 %CD% -r -R
    echo Example-filter-directory : %0 %CD% --nd "^(softwares|logs|data|target|bin|obj|Debug|Release)$" -r -R
    echo Example-filter-directory : %0 . --nd "^(softwares|logs|data|target|bin|obj|Debug|Release)$" -r -R
    echo Example-filter-directory : %0 %%CD%% --nd "^(softwares|logs|data|target|bin|obj|Debug|Release)$" -r -R
    exit /b 5
)

:: first argument must be the path, just like above examples.
%~dp0..\lzmw -it "^(\s*@\s*echo)\s+off\b" -o "$1 on" -f "\.(bat|cmd)$" -p %* 
