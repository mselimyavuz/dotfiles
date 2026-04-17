#!/bin/zsh
INTERNAL="eDP-1"
EXTERNAL=$(xrandr --query | grep " connected" | grep -v "^$INTERNAL" | awk '{print $1}' | head -n 1)

if [[ -z "$EXTERNAL" ]]; then
    xrandr --output "$INTERNAL" --auto --primary
    exit 0
fi

# --- Detect current state ---
INTERNAL_STATE=$(xrandr --query | grep "^$INTERNAL" | grep -o "[0-9]*x[0-9]*+[0-9]*+[0-9]*" | head -n 1)
EXTERNAL_STATE=$(xrandr --query | grep "^$EXTERNAL" | grep -o "[0-9]*x[0-9]*+[0-9]*+[0-9]*" | head -n 1)

if [[ -z "$INTERNAL_STATE" && -n "$EXTERNAL_STATE" ]]; then
    CURRENT="External Only"
elif [[ -n "$INTERNAL_STATE" && -z "$EXTERNAL_STATE" ]]; then
    CURRENT="Laptop Only"
elif [[ -n "$INTERNAL_STATE" && -n "$EXTERNAL_STATE" ]]; then
    INT_X=$(echo "$INTERNAL_STATE" | grep -o "+[0-9]*+[0-9]*$" | cut -d+ -f2)
    EXT_X=$(echo "$EXTERNAL_STATE" | grep -o "+[0-9]*+[0-9]*$" | cut -d+ -f2)
    if [[ "$INT_X" -lt "$EXT_X" ]]; then
        CURRENT="Extend: External to the Right"
    elif [[ "$INT_X" -gt "$EXT_X" ]]; then
        CURRENT="Extend: External to the Left"
    else
        CURRENT="Mirror"
    fi
else
    CURRENT="Unknown"
fi

HEADER="Current: $CURRENT  |  Internal: ${INTERNAL_STATE:-off}  |  External: ${EXTERNAL_STATE:-off}"

# --- Show menu ---
selected=$(printf '%s\n' \
    "Extend: External to the Right" \
    "Extend: External to the Left" \
    "Mirror: Same as Laptop" \
    "External Only: Turn off Laptop" \
    "Laptop Only: Turn off External" \
    "HiDPI Fix: Scale External 1.5x" \
    | fzf \
    --reverse \
    --header="$HEADER" \
    --color="bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#83a598,pointer:#fb4934,marker:#fabd2f,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934" \
    --prompt="Monitor λ " \
    --border=none)

if [[ -z "$selected" ]]; then
    exit 0
fi

case "$selected" in
    *"Right"*)
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        ;;
    *"Left"*)
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --left-of "$INTERNAL"
        ;;
    *"Mirror"*)
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        ;;
    *"External Only"*)
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary
        ;;
    *"Laptop Only"*)
        xrandr --output "$EXTERNAL" --off --output "$INTERNAL" --auto --primary
        ;;
    *"HiDPI Fix"*)
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --scale 1.5x1.5 --right-of "$INTERNAL"
        ;;
esac

~/.local/bin/polybar-launch.sh &

