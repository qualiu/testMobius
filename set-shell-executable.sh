if [ -n "$(uname -a | egrep -ie "^\s*cygwin")" ]; then
    for ff in $(lzmw -rp . -f "\.sh$" -l --nd "^(softwares)$" -PAC | lzmw -x \\ -o / -PAC); do dos2unix $ff; done
    #lzmw -f "\.sh$" -rp . -l -PAC --nd "^(softwares)$" | lzmw -x \\ -o / -PAC | xargs -I file sh -c "chmod +x file; dos2unix file"
else
    lzmw -f "\.sh$" -rp . -l -PAC --nd "^(softwares)$" | xargs -I file sh -c "chmod +x file; dos2unix file"
fi
