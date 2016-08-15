command="git status | lzmw -it '^#?\s*(?:modif|delet|new file)\w*\s*:\s+(../[^/]+.*)$' -o '"'$1'"' -PAC"
if [ "$1" = "1" ]; then
    command="$command | xargs -I file git reset file"
fi

bash -c "$command"
