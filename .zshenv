# General Wayland Environment
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland;xcb"
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# Hardware-Specific Overrides
if [[ "$(hostname)" == "selim-desktop" ]]; then
    export XDG_CURRENT_DESKTOP=sway
    export WLR_NO_HARDWARE_CURSORS=1
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
else
    export XDG_CURRENT_DESKTOP=wlroots
    unset GBM_BACKEND
    unset __GLX_VENDOR_LIBRARY_NAME
    unset WLR_NO_HARDWARE_CURSORS
fi
