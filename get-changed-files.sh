if [ "$1" = "1" ]; then
    git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o '$1' --nt "\(|:\s*$|\s+branch\s+" -PAC | xargs git add 
else
    git status | lzmw --nt "(cpp|logs|apps|checkDir)/|\s+../" -PAC | lzmw -it "^#?\s+(?:modif|new\s+file|delet)\w*\s*:\s*(\w+\S+)$" -o '$1' --nt "\(|:\s*$|\s+branch\s+" -PAC
fi
