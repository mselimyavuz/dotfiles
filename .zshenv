# ~/.zshenv
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

export WLR_NO_HARDWARE_CURSORS=1
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

export PATH="$PATH:/home/mselimyavuz/lilypond/bin/"
export PATH="$PATH:/home/mselimyavuz/.cargo/bin"
export PATH="$PATH:/home/mselimyavuz/.local/bin"
export PATH="$PATH:$HOME/dotfiles/scripts"
export PATH="$PATH:$HOME/workspace/main/scripts"

export LV2_PATH="$HOME/.lv2:/usr/local/lib64/lv2:/usr/lib64/lv2"
export VST3_PATH="$HOME/.vst3:/usr/local/lib64/vst3:/usr/lib64/vst3"

export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH

export JUCE_DIR="$HOME/.local/lib/cmake/JUCE"

export NVIM_LOG_FILE="$HOME/.local/state/nvim/log"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

export VISUAL="$EDITOR"

