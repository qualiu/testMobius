if [ "$1" = "1" ]; then
    if [ -n "$(uname -a | egrep -ie "^\s*cygwin")" ]; then
        for ff in $(git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o '$1' --nt "\(|:\s*$|\s+branch\s+" -PAC); do git add $ff; done
    else
        git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o '$1' --nt "\(|:\s*$|\s+branch\s+" -PAC | xargs git add 
    fi
else
    git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o '$1' --nt "\(|:\s*$|\s+branch\s+" -PAC
fi
