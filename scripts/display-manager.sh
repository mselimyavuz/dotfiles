#!/bin/zsh
INTERNAL="eDP-1"
INT_SCALE="1.351562"

# Get the external monitor name
EXTERNAL=$(wlr-randr | grep -v "$INTERNAL" | grep -E '^[a-zA-Z0-9-]+' | awk '{print $1}' | head -n 1)

# Debug: Print found monitor
echo "Debug: Detected External as [$EXTERNAL]"

if [[ -z "$EXTERNAL" ]]; then
    echo "No external monitor found. Resetting internal."
    wlr-randr --output "$INTERNAL" --on --scale "$INT_SCALE" --pos 0,0
    exit 0
fi

# Simplified Header
HEADER="External Monitor: $EXTERNAL detected"

# Show the menu
selected=$(printf '%s\n' \
    "Extend: Right" \
    "Extend: Left" \
    "Mirror" \
    "External Only" \
    "Laptop Only" \
    | fzf --reverse --header="$HEADER")

[[ -z "$selected" ]] && exit 0

echo "Selected: $selected"

case "$selected" in
    "Extend: Right")
        # Logical width of eDP-1 is roughly 2131
        wlr-randr --output "$INTERNAL" --on --pos 0,0 --scale "$INT_SCALE"
        wlr-randr --output "$EXTERNAL" --on --pos 2131,0 --scale 1
        ;;
    "Extend: Left")
    # Force a state reset to prevent 'sticky' mirroring
    wlr-randr --output "$EXTERNAL" --off
    sleep 0.1
    wlr-randr --output "$EXTERNAL" --on --pos 0,0 --scale 1
    wlr-randr --output "$INTERNAL" --on --pos 1920,0 --scale "$INT_SCALE"
    ;;
    "Mirror")
    # Reset both to be sure
    wlr-randr --output "$INTERNAL" --on --pos 0,0 --scale "$INT_SCALE"
    wlr-randr --output "$EXTERNAL" --on --pos 0,0 --scale 1 --mode 1920x1080
    ;;
    "External Only")
        # Turn off internal FIRST
        wlr-randr --output "$INTERNAL" --off
        wlr-randr --output "$EXTERNAL" --on --pos 0,0 --scale 1
        ;;
    "Laptop Only")
        wlr-randr --output "$EXTERNAL" --off
        wlr-randr --output "$INTERNAL" --on --pos 0,0 --scale "$INT_SCALE"
        ;;
esac
