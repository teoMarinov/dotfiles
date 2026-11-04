#!/bin/bash

set -e

# ── Colors ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${BLUE}→${NC} $1"; }
ok()   { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✘${NC} $1"; }

log "Copying dotfiles from config"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log $SCRIPT_DIR
CONFIG_DIRS=(hypr kitty ohmyposh rofi swaync waybar)

for dir in "${CONFIG_DIRS[@]}"; do
  if [ -d "$HOME/.config/$dir" ]; then
   rm -rf "$SCRIPT_DIR/config/$dir"
   cp -r "$HOME/.config/$dir" "$SCRIPT_DIR/config/"
   ok "Updated $dir"
  else
    warn "Missing config: $HOME/.config/$dir" 
  fi
done

log "Copying home files"

HOME_FILES=(.zshrc .zprofile)
mkdir -p "$SCRIPT_DIR/home"

for file in "${HOME_FILES[@]}"; do
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$SCRIPT_DIR/home/$file"
    ok "Updated $file"
  else
    warn "Missing home file: $HOME/$file"
  fi
done

ok "Dotfiles copied from system"
