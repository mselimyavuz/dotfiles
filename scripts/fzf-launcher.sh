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

# Detect compositor
if [[ -n "$SWAYSOCK" ]] || pgrep -x sway &>/dev/null; then
    WM_EXEC="swaymsg exec"
elif [[ -n "$I3SOCK" ]] || pgrep -x i3 &>/dev/null; then
    WM_EXEC="i3-msg exec"
else
    WM_EXEC="exec"
fi

if [[ ! -f "$CACHE_FILE" ]]; then
    build_cache
fi

output=$(echo "↺ Rebuild cache\n$(cat "$CACHE_FILE")" | fzf --reverse --print-query \
    --color="bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#83a598,pointer:#fb4934,marker:#fabd2f,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934" \
    --prompt="λ " --border=none)

query=$(echo "$output" | head -1)
selected=$(echo "$output" | tail -1)
[[ "$query" == "$selected" ]] && selected=""

if [[ -n "$query" && -z "$selected" ]]; then
    $WM_EXEC "$query"
elif [[ -n "$selected" ]]; then
    if [[ "$selected" == "↺ Rebuild cache" ]]; then
        build_cache
    else
        cmd=$(echo "$selected" | sed 's/.*(\(.*\))/\1/' | xargs)
        $WM_EXEC "$cmd"
    fi
fi

