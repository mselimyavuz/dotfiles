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
    "gui-wm/swayfx"
    "gui-apps/waybar"
    "gui-apps/mako"
    "media-video/mpv"
    "sys-process/btop"
    "app-misc/fastfetch"
    "gui-apps/foot"
    "app-editors/neovim"
    "app-admin/s-tui"
    "sys-fs/gdu"
    "sys-apps/bat"
    "gui-apps/kanshi"
    "app-text/zathura"
    "app-text/zathura-pdf-poppler"
    "app-misc/ranger"
    "mail-client/aerc"
    "app-shells/fzf"
    "media-sound/pavucontrol"
    "x11-misc/gammastep"
    "gnome-base/gnome-keyring"
    "x11-themes/chameleon-xcursors"
    "media-fonts/nerdfonts"
    "x11-apps/xhost"
    "gui-apps/wl-clipboard"
    "sys-apps/xdg-desktop-portal"
    "sys-apps/xdg-desktop-portal-wlr"
    "sys-apps/xdg-desktop-portal-gtk"
    "sys-apps/dbus"
    "sys-apps/xdg-dbus-proxy"
)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}::: Starting Gentoo Dotfiles Setup :::${NC}"

# ==========================================
# 0. DISTRO CHECK
# ==========================================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "gentoo" || "$ID_LIKE" == *"gentoo"* ]]; then
        echo -e "${GREEN}✓ Detected Gentoo system.${NC}"
    else
        echo -e "${RED}ERROR: This script is intended for Gentoo systems.${NC}"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
    fi
fi

# ==========================================
# 1. CORE TOOLS CHECK
# ==========================================
echo -e "\n${BLUE}[1/6] Checking Core Tools...${NC}"
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
# 2. REPO CHECK (GURU)
# ==========================================
echo -e "\n${BLUE}[2/5] Checking GURU Overlay...${NC}"
if eselect repository list -i | grep -qE "\s+guru\s+"; then
    echo -e "${GREEN}✓ GURU overlay active.${NC}"
else
    sudo eselect repository enable guru
    sudo emaint sync -r guru
fi

# ==========================================
# 3. PACKAGE INSTALLATION
# ==========================================
echo -e "\n${BLUE}[3/6] Checking System Packages...${NC}"
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
# 4. CLEANUP ROUTINE (Matches current structure)
# ==========================================
echo -e "\n${BLUE}[4/6] Cleaning old configurations...${NC}"
REMOVE_LIST=(
    "$HOME/.zshrc" "$HOME/.Xresources" "$HOME/.tmux.conf" "$HOME/.tmux"
    "$HOME/.config/btop" "$HOME/.config/fastfetch" "$HOME/.config/foot"
    "$HOME/.config/mako" "$HOME/.config/mpv" "$HOME/.config/nvim"
    "$HOME/.config/sway" "$HOME/.config/waybar"
    "$HOME/.config/ranger" "$HOME/.config/aerc" "$HOME/.config/termusic"
    "$HOME/.config/euporie" "$HOME/.config/zathura"
    "$HOME/.local/bin/portage-cleaner.py"
    "$HOME/.local/bin/fzf-launcher.sh"
    "$HOME/.local/bin/mail-sync.sh" "$HOME/.urlview"
    "$HOME/.config/oh-my-posh-theme.json"
)

for item in "${REMOVE_LIST[@]}"; do
    if [ -e "$item" ] || [ -h "$item" ]; then
        rm -rf "$item"
        echo -e "${RED}Deleted:${NC} $item"
    fi
done

# ==========================================
# 5. LINKING ROUTINE
# ==========================================
echo -e "\n${BLUE}[5/6] Linking new configurations...${NC}"
link_config() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        echo -e "${GREEN}Linked:${NC} $dest -> $src"
    else
        echo -e "${YELLOW}Warning:${NC} Source $src not found. Skipping."
    fi
}

link_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
link_config "$DOTFILES_DIR/wayland.tmux.conf" "$HOME/.tmux.conf"
link_config "$DOTFILES_DIR/.tmux" "$HOME/.tmux"
link_config "$DOTFILES_DIR/oh-my-posh-theme.json" "$HOME/.config/oh-my-posh-theme.json"
link_config "$DOTFILES_DIR/.urlview" "$HOME/.urlview"

if [ -d "$DOTFILES_DIR/scripts" ]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
        script_name=$(basename "$script")
        link_config "$script" "$HOME/.local/bin/$script_name"
    done
fi

CONFIGS=(
    "aerc" "btop" "euporie" "fastfetch" "foot" "mako" 
    "mpv" "nvim" "ranger" "sway" "termusic" "waybar" 
    "zathura"
)

for cfg in "${CONFIGS[@]}"; do
    link_config "$DOTFILES_DIR/$cfg" "$HOME/.config/$cfg"
done

# ==========================================
# 6. POST-INSTALL & PERMISSIONS
# ==========================================
echo -e "\n${BLUE}[6/6] Setting permissions...${NC}"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo -e "\n${BLUE}Installing TPM...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

find "$DOTFILES_DIR/scripts" -type f -exec chmod +x {} +

echo -e "\n${GREEN}::: Setup Complete! Re-login or source ~/.zshrc and build Ferdi265/wl-mirror if you want present mode to work :::${NC}"

