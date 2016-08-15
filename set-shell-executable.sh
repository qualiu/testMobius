#!/bin/bash
ShellDir=$(cd $(dirname $0) && pwd)
source ~/.bashrc
lzmwPath=$(whereis lzmw 2>/dev/null)
if [ -z "$lzmwPath" ] || [ ! -f "$lzmwPath" ]; then
    if [ -n "$(uname -a | egrep -ie "^\s*cygwin")" ]; then
        lzmwPath=$ShellDir/tools/lzmw.cygwin
    else
        lzmwPath=$(ls $ShellDir/tools/lzmw.gcc* | tail -n 1)
    fi
    cd $(dirname $lzmwPath) && ln -sf $(basename $lzmwPath) lzmw
    cd $ShellDir
    export PATH=$PATH:$ShellDir/tools

    grepToolResult=$(cat ~/.bashrc | egrep -ie "$ShellDir/tools")
    if [ -z "$grepToolResult" ]; then
cat >> ~/.bashrc <<EOF
export PATH=\$PATH:$ShellDir/tools
alias lzmw=$lzmwPath
EOF
    source ~/.bashrc
    fi
fi

if [ -n "$(uname -a | egrep -ie "^\s*cygwin")" ]; then
    for ff in $(lzmw -rp . -f "\.sh$" -l --nd "^(softwares)$" -PAC | lzmw -x \\ -o / -PAC); do dos2unix $ff; done
    #lzmw -f "\.sh$" -rp . -l -PAC --nd "^(softwares)$" | lzmw -x \\ -o / -PAC | xargs -I file sh -c "chmod +x file; dos2unix file"
else
    lzmw -f "\.sh$" -rp . -l -PAC --nd "^(softwares)$" | xargs -I file sh -c "chmod +x file; dos2unix file"
fi
