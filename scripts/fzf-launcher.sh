#!/bin/zsh
CACHE_FILE="/tmp/fzf_launcher_cache_$USER"

build_cache() {
    local execs=$(whence -pm "*" | xargs -n1 basename | awk '{print $1 " (" $1 ")"}')
    
    local desktops=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | xargs awk -F= '
        /^Name=/ {name=$2} 
        /^Exec=/ {exec=$2; if(name && exec) {gsub(/%[a-zA-Z]/, "", exec); print name " (" exec ")"}}
    ' 2>/dev/null)
    
    echo -e "$execs\n$desktops" | sort -u > "$CACHE_FILE"
}

if [[ ! -f "$CACHE_FILE" ]]; then
    build_cache
fi

selected=$(echo "↺ Rebuild cache\n$(cat "$CACHE_FILE")" | fzf --reverse \
    --color="bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#83a598,pointer:#fb4934,marker:#fabd2f,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934" \
    --prompt="λ " --border=none)

if [[ -n "$selected" ]]; then
    if [[ "$selected" == "↺ Rebuild cache" ]]; then
        build_cache
    else
        cmd=$(echo "$selected" | sed 's/.*(\(.*\))/\1/' | xargs)
        i3-msg exec "$cmd"
    fi
fi

