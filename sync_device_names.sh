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

# ── Target Files ───────────────────────────
CONFIG_DIR="$HOME/.config/hypr/configs"
ENV_CONF="$CONFIG_DIR/ENVariables.conf"
CTL_CONF="$CONFIG_DIR/CTL.conf"

# ── Detect AQ_DRM_DEVICES ─────────────────────────────────────────────────────
log "Detecting GPU card paths..."

AMD_CARD=""
NVIDIA_CARD=""

# Iterate through the physical PCI paths to find which card is which
for path in /dev/dri/by-path/*-card; do
    # Get the PCI ID from the symlink name
    pci_id=$(basename "$path" | sed 's/pci-\(.*\)-card/\1/')
    # Resolve the symlink to the actual device (e.g., /dev/dri/card1)
    card_dev=$(realpath "$path")
    
    # Check vendor via lspci
    vendor=$(lspci -s "$pci_id" 2>/dev/null)
    
    if echo "$vendor" | grep -qi "AMD"; then
        AMD_CARD="$card_dev"
    elif echo "$vendor" | grep -qi "NVIDIA"; then
        NVIDIA_CARD="$card_dev"
    fi
done

if [ -z "$AMD_CARD" ] || [ -z "$NVIDIA_CARD" ]; then
    err "Could not detect both GPUs."
    warn "AMD: ${AMD_CARD:-MISSING}, NVIDIA: ${NVIDIA_CARD:-MISSING}"
else
    # Aquamarine usually wants the iGPU (AMD) first for the internal display
    AQ_VALUE="$AMD_CARD:$NVIDIA_CARD"
    log "Detected: AMD=$AMD_CARD | NVIDIA=$NVIDIA_CARD"
    
    if [ -f "$ENV_CONF" ]; then
        sed -i "s|env = AQ_DRM_DEVICES,.*|env = AQ_DRM_DEVICES,$AQ_VALUE|" "$ENV_CONF"
        ok "Updated AQ_DRM_DEVICES in ENVariables.conf"
    else
        err "File not found: $ENV_CONF"
    fi
fi

# ── Detect Brightness Device ──────────────────────────────────────────────────
log "Detecting brightness device..."

# Look for the amdgpu backlight specifically
BL_DEVICE=$(brightnessctl --list -m | grep "amdgpu_bl" | cut -d, -f1 | head -n1)

if [ -z "$BL_DEVICE" ]; then
    # Fallback to any backlight if amdgpu_bl isn't found
    BL_DEVICE=$(brightnessctl --list -m | grep "backlight" | cut -d, -f1 | head -n1)
fi

if [ -n "$BL_DEVICE" ]; then
    log "Found backlight: $BL_DEVICE"
    if [ -f "$CTL_CONF" ]; then
        # This replaces any 'amdgpu_blX' with the newly detected one
        sed -i "s/amdgpu_bl[0-9]*/$BL_DEVICE/g" "$CTL_CONF"
        ok "Updated brightness device in CTL.conf"
    else
        err "File not found: $CTL_CONF"
    fi
else
    err "No brightness device detected."
fi

echo -e "\n${GREEN}Sync complete!${NC} Your Hyprland configs are now hardware-matched."
