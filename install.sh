#!/bin/bash

ECHO "Starting installation script"

set -e

# ── Colors ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}→${NC} $1"; }
ok()  { echo -e "${GREEN}✔${NC} $1"; }

# ── Packages ───────────────────────────────────────────────────────────────────
PACMAN_PACKAGES=(
    git
    neovim
    zsh
    unzip
    fzf
    eza
    bc
    blueman
    brightnessctl
    btop
    cliphist
    grim
    hyprlock
    jq
    less
    loupe
    keyd
    noto-fonts-emoji
    noto-fonts-cjk
    slurp
    swaync
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    waybar
    xdg-desktop-portal-gtk
    pavucontrol
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

# ── Install pacman packages ────────────────────────────────────────────────────
install_pacman() {
    log "Installing pacman packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
    ok "Pacman packages installed"
}

# ── Install AUR packages ───────────────────────────────────────────────────────
install_aur() {
    log "Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    ok "AUR packages installed"
}

# ── Main ───────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║        01 - Package Installation     ║"
echo "╚══════════════════════════════════════╝"
echo ""

install_yay
install_pacman
install_aur

echo ""
ok "All packages installed"

echo "Starting applying configs"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIRS=(hypr kitty ohmyposh rofi swaync waybar)
HOME_FILES=(.zshrc .zprofile)

# ── Config files ───────────────────────────────────────────────────────────────
log "Copying config files to ~/.config/..."
for dir in "${CONFIG_DIRS[@]}"; do
    src="$SCRIPT_DIR/config/$dir"
    dest="$HOME/.config/$dir"

    if [ ! -d "$src" ]; then
        echo "  ⚠ Skipping $dir — not found in ./config/"
        continue
    fi

    rm -rf "$dest"
    cp -r "$src" "$dest"
    ok "$dir → ~/.config/$dir"
done

# ── Home files ─────────────────────────────────────────────────────────────────
log "Copying home files to ~/..."
for file in "${HOME_FILES[@]}"; do
    src="$SCRIPT_DIR/home/$file"

    if [ ! -f "$src" ]; then
        echo "  ⚠ Skipping $file — not found in ./home/"
        continue
    fi

    cp "$src" "$HOME/$file"
    ok "$file → ~/$file"
done

echo ""
ok "Dotfiles copied"

echo "setting up system changes"
ETC="$SCRIPT_DIR/etc"
 
# ── GRUB — update only GRUB_CMDLINE_LINUX_DEFAULT ─────────────────────────────
log "Updating GRUB_CMDLINE_LINUX_DEFAULT..."
NEW_LINE=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$ETC/default/grub")
sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$NEW_LINE|" /etc/default/grub
ok "GRUB cmdline updated"
 
# ── mkinitcpio — update only MODULES line ─────────────────────────────────────
log "Updating mkinitcpio MODULES..."
NEW_MODULES=$(grep '^MODULES=' "$ETC/mkinitcpio.conf")
sudo sed -i "s|^MODULES=.*|$NEW_MODULES|" /etc/mkinitcpio.conf
ok "mkinitcpio MODULES updated"
 
# ── keyd — full copy ───────────────────────────────────────────────────────────
log "Copying keyd config..."
sudo cp -r "$ETC/keyd/." /etc/keyd/
ok "keyd config copied"
 
# ── modprobe.d — full copy ─────────────────────────────────────────────────────
log "Copying modprobe.d config..."
sudo cp -r "$ETC/modprobe.d/." /etc/modprobe.d/
ok "modprobe.d config copied"
 
# ── Apply changes ──────────────────────────────────────────────────────────────
log "Rebuilding initramfs..."
sudo mkinitcpio -P
 
log "Rebuilding GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# ── Disable SDDM ───────────────────────────────────────────────────────────────
log "Disabling SDDM..."
if systemctl is-enabled sddm &>/dev/null; then
    sudo systemctl disable sddm
    ok "SDDM disabled"
else
    ok "SDDM already disabled, skipping"
fi
 
# ── Enable keyd ────────────────────────────────────────────────────────────────
log "Enabling and restarting keyd..."
sudo systemctl enable keyd
sudo systemctl restart keyd
ok "keyd enabled and running"

# ── Change shell to zsh ────────────────────────────────────────────────────────
log "Setting zsh as default shell..."
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh "$USER"
    ok "Shell changed to zsh"
else
    ok "zsh already default shell, skipping"
fi
 
# ── Set Loupe as default image viewer ─────────────────────────────────────────
log "Setting Loupe as default image viewer..."
for mime in image/jpeg image/png image/webp image/gif image/tiff image/bmp image/svg+xml; do
    xdg-mime default org.gnome.Loupe.desktop $mime
done
ok "Loupe set as default image viewer"
 
echo ""
ok "System config applied"

read -p "Reboot now? [Y/n] " answer
answer=${answer:-y}
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sync && reboot
else
    echo "Skipping reboot. Remember to reboot before running 04-services.sh"
fi
