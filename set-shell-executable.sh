if [ -n "$(uname -a | egrep -ie "^\s*cygwin")" ]; then
    lzmw -f "\.sh$" -rp . -l -PAC | lzmw -x \\ -o / -PAC | xargs -I file sh -c "chmod +x file; dos2unix file"
else
    lzmw -f "\.sh$" -rp . -l -PAC | xargs -I file sh -c "chmod +x file; dos2unix file"
fi
