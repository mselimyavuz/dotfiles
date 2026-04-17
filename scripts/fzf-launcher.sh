#!/bin/zsh
CACHE_FILE="/tmp/fzf_launcher_cache_$USER"

build_cache() {
    local execs=$(echo "$PATH" | tr ':' '\n' | while read dir; do
        [[ -d "$dir" ]] && find "$dir" -maxdepth 1 -type f -executable 2>/dev/null
    done | xargs -r -n1 basename | sort -u | awk '{print $1 " (" $1 ")"}')

    local desktops=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | xargs awk -F= '
        /^Name=/ {name=$2} 
        /^Exec=/ {exec=$2; if(name && exec) {gsub(/%[a-zA-Z]/, "", exec); print name " (" exec ")"}}
    ' 2>/dev/null)

    echo -e "$execs\n$desktops" | sort -u > "$CACHE_FILE"
}

if [[ ! -f "$CACHE_FILE" ]]; then
    build_cache
fi

output=$(echo "↺ Rebuild cache\n$(cat "$CACHE_FILE")" | fzf --reverse --print-query \
    --color="bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#83a598,pointer:#fb4934,marker:#fabd2f,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934" \
    --prompt="λ " --border=none)

query=$(echo "$output" | head -1)
selected=$(echo "$output" | tail -1)

# tail -1 returns the query again if nothing was selected
[[ "$query" == "$selected" ]] && selected=""

if [[ -n "$query" && -z "$selected" ]]; then
    # nothing matched — run raw input as a path/command
    i3-msg exec "$query"
elif [[ -n "$selected" ]]; then
    if [[ "$selected" == "↺ Rebuild cache" ]]; then
        build_cache
    else
        cmd=$(echo "$selected" | sed 's/.*(\(.*\))/\1/' | xargs)
        i3-msg exec "$cmd"
    fi
fi

