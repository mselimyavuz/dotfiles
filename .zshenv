# --- Global Wayland & Toolkit Consistency ---
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export ELECTRON_OZONE_PLATFORM_HINT="auto"
export GDK_BACKEND="wayland,x11"

# --- Theme & Aesthetics ---
export GTK_THEME="Adwaita:dark"
export ADW_DISABLE_PORTAL=1

# --- Hardware & WM Specific Overrides ---
if [[ "$(hostname)" == "selim-desktop" ]]; then
    export XDG_CURRENT_DESKTOP=sway
    export QT_QPA_PLATFORM="wayland"
    export QT_QPA_PLATFORMTHEME="qt5ct"
    
    # NVIDIA Specifics
    export WLR_NO_HARDWARE_CURSORS=1
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
else
    # ThinkPad X1 Carbon (dwl / Intel)
    export XDG_CURRENT_DESKTOP=wlroots
    export QT_QPA_PLATFORM="wayland;xcb"

    unset GBM_BACKEND
    unset __GLX_VENDOR_LIBRARY_NAME
    unset WLR_NO_HARDWARE_CURSORS
fi
