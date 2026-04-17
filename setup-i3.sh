#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
DOTFILES_DIR="$HOME/dotfiles"

if [ -z "$HOME" ] || [ -z "$DOTFILES_DIR" ]; then
    echo -e "\033[0;31mERROR: HOME or DOTFILES_DIR is not set. Exiting.\033[0m"
    exit 1
fi

PACKAGES=(
    "app-shells/zsh"
    "app-misc/tmux"
    "x11-wm/i3"
    "x11-misc/polybar"
    "x11-misc/dunst"
    "x11-misc/picom"
    "x11-apps/setxkbmap"
    "x11-apps/xrandr"
    "x11-misc/xclip"
    "media-gfx/maim"
    "x11-terms/st"
    "x11-apps/xinput"
    "media-video/mpv"
    "sys-process/btop"
    "app-misc/fastfetch"
    "app-editors/neovim"
    "app-text/zathura"
    "app-text/zathura-pdf-poppler"
    "app-misc/ranger"
    "mail-client/aerc"
    "app-shells/fzf"
    "media-sound/pavucontrol"
    "app-misc/brightnessctl"
    "media-gfx/feh"
    "x11-misc/gammastep"
    "gnome-base/gnome-keyring"
)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}::: Starting Gentoo X11/i3 Dotfiles Setup :::${NC}"

# ==========================================
# 0. DISTRO CHECK
# ==========================================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "gentoo" || "$ID_LIKE" == *"gentoo"* ]]; then
        echo -e "${GREEN}✓ Detected Gentoo system.${NC}"
    else
        echo -e "${RED}ERROR: This script is intended for Gentoo systems.${NC}"
        exit 1
    fi
fi

# ==========================================
# 1. CORE TOOLS CHECK
# ==========================================
echo -e "\n${BLUE}[1/5] Checking Core Tools...${NC}"
for tool in "app-portage/portage-utils:qlist" "app-portage/gentoolkit:equery" "app-eselect/eselect-repository:eselect"; do
    PKG="${tool%%:*}"
    CMD="${tool#*:}"

    if command -v "$CMD" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $CMD is available ($PKG).${NC}"
    else
        echo -e "${YELLOW}Binary '$CMD' not found. Checking Portage database for $PKG...${NC}"

	if [ -d "/var/db/pkg/$PKG"* ]; then
             echo -e "${BLUE}i $PKG is recorded as installed, but $CMD is not in PATH.${NC}"
        else
             echo -e "${RED}! $PKG not found. Installing...${NC}"
             sudo emerge -n "$PKG"
        fi
    fi
done

# ==========================================
# 2. PACKAGE INSTALLATION
# ==========================================
echo -e "\n${BLUE}[2/5] Checking System Packages...${NC}"
PACKAGES_TO_INSTALL=()
for pkg in "${PACKAGES[@]}"; do
    if qlist -IC "$pkg" > /dev/null; then
        echo -e "${GREEN}✓ $pkg is installed.${NC}"
    else
        PACKAGES_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -ne 0 ]; then
    sudo emerge --noreplace --ask --verbose "${PACKAGES_TO_INSTALL[@]}"
fi

# ==========================================
# 3. CLEANUP ROUTINE
# ==========================================
echo -e "\n${BLUE}[3/5] Cleaning old configurations...${NC}"
REMOVE_LIST=(
    "$HOME/.zshrc" "$HOME/.Xresources" "$HOME/.tmux.conf"
    "$HOME/.config/btop" "$HOME/.config/fastfetch"
    "$HOME/.config/mako" "$HOME/.config/nvim"
    "$HOME/.config/sway" "$HOME/.config/waybar"
    "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/dunst" "$HOME/.config/picom"
    "$HOME/.config/ranger" "$HOME/.config/aerc" "$HOME/.config/termusic"
    "$HOME/.config/zathura" "$HOME/.local/bin/fzf-launcher.sh"
    "$HOME/.urlview"
)

for item in "${REMOVE_LIST[@]}"; do
    if [ -e "$item" ] || [ -h "$item" ]; then
        rm -rf "$item"
        echo -e "${RED}Deleted:${NC} $item"
    fi
done

# ==========================================
# 4. LINKING ROUTINE
# ==========================================
echo -e "\n${BLUE}[4/5] Linking new configurations...${NC}"
link_config() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
        echo -e "${GREEN}Linked:${NC} $dest -> $src"
    else
        echo -e "${YELLOW}Warning:${NC} Source $src not found. Skipping."
    fi
}

link_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
link_config "$DOTFILES_DIR/x11.tmux.conf" "$HOME/.tmux.conf"
link_config "$DOTFILES_DIR/oh-my-posh-theme.json" "$HOME/.config/oh-my-posh-theme.json"
link_config "$DOTFILES_DIR/.urlview" "$HOME/.urlview"

if [ -d "$DOTFILES_DIR/scripts" ]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
        script_name=$(basename "$script")
        link_config "$script" "$HOME/.local/bin/$script_name"
    done
fi

CONFIG_DIRS=("aerc" "btop" "dunst" "euporie" "fastfetch" "i3" "mpv" "nvim" "picom" "polybar" "ranger" "termusic" "zathura")
for dir in "${CONFIG_DIRS[@]}"; do
    link_config "$DOTFILES_DIR/$dir" "$HOME/.config/$dir"
done

# ==========================================
# 5. PERMISSIONS & POST-INSTALL
# ==========================================
echo -e "\n${BLUE}[5/5] Setting permissions...${NC}"
find "$DOTFILES_DIR/scripts" -type f -exec chmod +x {} +
[ -f "$HOME/.config/polybar/polybar-launch.sh" ] && chmod +x "$HOME/.config/polybar/polybar-launch.sh"

if [ -d "$DOTFILES_DIR/st-0.9.3" ]; then
    echo -e "${YELLOW}Reminder: Build st manually from $DOTFILES_DIR/st-0.9.3${NC}"
fi

echo -e "\n${GREEN}::: Setup Complete! Re-login or source ~/.zshrc and rebuild x11-terms/st with savedconfig in /etc/portage/saved/x11-terms/st* :::${NC}"

