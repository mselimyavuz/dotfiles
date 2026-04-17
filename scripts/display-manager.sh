#!/bin/zsh

INTERNAL="eDP-1"
EXTERNAL=$(xrandr --query | grep " connected" | grep -v "$INTERNAL" | awk '{print $1}' | head -n 1)

if [[ -z "$EXTERNAL" ]]; then
    echo "No external display detected. Resetting to internal only..."
    xrandr --output "$INTERNAL" --auto --primary
    exit 0
fi

options=(
    "Extend: External to the Right"
    "Extend: External to the Left"
    "Mirror: Same as Laptop"
    "External Only: Turn off Laptop"
    "Laptop Only: Turn off External"
    "HiDPI Fix: Scale External 1.5x"
)

selected=$(printf "%s\n" "${options[@]}" | fzf \
    --reverse \
    --color="bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#83a598,pointer:#fb4934,marker:#fabd2f,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934" \
    --prompt="Monitor λ " \
    --border=none)

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
        # Useful for 4K laptop -> 1080p monitor mapping
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --scale 1.5x1.5 --right-of "$INTERNAL"
        ;;
esac

if pgrep polybar > /dev/null; then
    ~/.config/polybar/polybar-launch.sh &
fi

