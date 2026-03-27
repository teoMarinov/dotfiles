#!/bin/bash

# Stop on any error
set -e

# ── Colors ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}→${NC} $1"; }
ok()  { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# ── Packages ───────────────────────────────────────────────────────────────────
# Added 'base-devel' here as it is required for building AUR packages
PACMAN_PACKAGES=(
    base-devel git neovim zsh unzip fzf eza bc blueman brightnessctl btop 
    cliphist grim hyprlock jq less loupe keyd noto-fonts-emoji noto-fonts-cjk 
    slurp swaync ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols waybar 
    xdg-desktop-portal-gtk pavucontrol xdg-utils
)

AUR_PACKAGES=(
    oh-my-posh
    flat-remix
    flat-remix-gtk
)

# ── Install yay ────────────────────────────────────────────────────────────────
install_yay() {
    if command -v yay &>/dev/null; then
        ok "yay already installed, skipping"
        return
    fi

    log "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay installed"
}

# ── Install Packages ───────────────────────────────────────────────────────────
install_packages() {
    log "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
    
    log "Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

# ── Main Script Execution ──────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║      Arch System Setup Script        ║"
echo "╚══════════════════════════════════════╝"

install_yay
install_packages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ETC_SRC="$SCRIPT_DIR/etc"

# ── Config files (.config) ─────────────────────────────────────────────────────
log "Applying dotfiles..."
mkdir -p "$HOME/.config"

CONFIG_DIRS=(hypr kitty ohmyposh rofi swaync waybar)
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/config/$dir" ]; then
        rm -rf "$HOME/.config/$dir"
        cp -r "$SCRIPT_DIR/config/$dir" "$HOME/.config/"
        ok "Configured: $dir"
    else
        warn "Missing config directory: $dir"
    fi
done

# ── Home files (.zshrc, etc) ───────────────────────────────────────────────────
HOME_FILES=(.zshrc .zprofile)
for file in "${HOME_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/home/$file" ]; then
        cp "$SCRIPT_DIR/home/$file" "$HOME/$file"
        ok "Configured: $file"
    fi
done

# ── System Level Changes (/etc) ───────────────────────────────────────────────
log "Applying system changes (/etc)..."

# GRUB Update
if [ -f "$ETC_SRC/default/grub" ]; then
    NEW_GRUB_CMD=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$ETC_SRC/default/grub")
    sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$NEW_GRUB_CMD|" /etc/default/grub
    ok "GRUB command line updated"
fi

# mkinitcpio Update
if [ -f "$ETC_SRC/mkinitcpio.conf" ]; then
    NEW_MODULES=$(grep '^MODULES=' "$ETC_SRC/mkinitcpio.conf")
    sudo sed -i "s|^MODULES=.*|$NEW_MODULES|" /etc/mkinitcpio.conf
    ok "mkinitcpio MODULES updated"
fi

# keyd & modprobe.d (Full Directory Sync)
sudo cp -r "$ETC_SRC/keyd/"* /etc/keyd/ 2>/dev/null || warn "keyd src empty"
sudo cp -r "$ETC_SRC/modprobe.d/"* /etc/modprobe.d/ 2>/dev/null || warn "modprobe src empty"

# ── Services & Shell ──────────────────────────────────────────────────────────
log "Managing services..."
sudo systemctl disable sddm || true
sudo systemctl enable --now keyd

log "Setting default shell to zsh..."
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
    ok "Shell changed to zsh"
fi

log "Setting Loupe as default viewer..."
# Ensure loupe desktop file exists before setting
if [ -f /usr/share/applications/org.gnome.Loupe.desktop ]; then
    for mime in image/jpeg image/png image/webp image/gif image/tiff image/bmp image/svg+xml; do
        xdg-mime default org.gnome.Loupe.desktop $mime
    done
    ok "Loupe defaults set"
fi

# ── Finalize ──────────────────────────────────────────────────────────────────
log "Regenerating system images..."
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\n${GREEN}Setup Complete!${NC}"
read -p "Reboot now? [Y/n] " answer
answer=${answer:-y}
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sync && reboot
fi
