export ZSH="$HOME/.oh-my-zsh"
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

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

export VISUAL="$EDITOR"

ZSH_THEME=""
plugins=(git ssh-agent fzf zsh-autosuggestions zsh-syntax-highlighting)

zstyle :omz:plugins:ssh-agent identities id_ed25519

source $ZSH/oh-my-zsh.sh

alias se='doas env XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share XDG_STATE_HOME=$HOME/.local/state nvim'
alias fix-phone='adb shell settings put global force_fsg_nav_bar 1 && adb shell settings put global hide_gesture_line 1'
alias ls="eza --icons --git --group-directories-first"
alias yabridge-sync='PATH="$HOME/opt/wine-9.21-staging-tkg-amd64-wow64/bin:$PATH" WINEPREFIX="$HOME/.wine-proaudio" yabridgectl sync'

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh-theme.json)"
fastfetch

yt-playlist() {
    yt-dlp -x --audio-format mp3 --audio-quality 0 --yes-playlist \
    --embed-metadata --embed-thumbnail \
    -o "%(playlist_index)s-%(title)s.%(ext)s" \
    --exec "post_process:echo '%(playlist_index)s-%(title)s.mp3' >> '%(playlist_title)s.m3u'" \
    "$1"
}

borg-backup() {
   sudo borg create --stats --progress --compression lz4 \
    --exclude-from ~/.config/borg-excludes.txt \
    /mnt/backup::gentoo-backup-$(date +%F) \
    /
}

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ------------------------ VI MODE & RPROMPT ------------------------
bindkey -v
export KEYTIMEOUT=1

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'e' edit-command-line

MODE_INSERT="%F{#111111}%K{#98c379} פּ INSERT %k%f"
MODE_NORMAL="%F{#111111}%K{#e06c75} פּ NORMAL %k%f"

function zle-keymap-select {
  case $KEYMAP in
    vicmd)      RPROMPT=$MODE_NORMAL ;;
    main|viins) RPROMPT=$MODE_INSERT ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-init {
  zle -K viins
  RPROMPT=$MODE_INSERT
  zle reset-prompt
}
zle -N zle-line-init

bindkey '^?' backward-delete-char
# -------------------------------------------------------------------

