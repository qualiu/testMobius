lzmw -f "\.sh$" -rp . -l -PAC | xargs -I file sh -c "chmod +x file; dos2unix file"
