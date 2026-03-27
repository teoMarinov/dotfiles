#!/bin/bash
 
set -e
 
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
 
log()  { echo -e "${BLUE}→${NC} $1"; }
ok()   { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✘${NC} $1"; }
 
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

# ── Detect AQ_DRM_DEVICES ─────────────────────────────────────────────────────
log "Detecting GPU card paths for AQ_DRM_DEVICES..."
 
AMD_CARD=""
NVIDIA_CARD=""
 
while IFS= read -r line; do
    pci=$(echo "$line" | grep -oP 'pci-\K[0-9a-f:]+(?=-card)')
    card=$(echo "$line" | grep -oP 'card\d+$')
    [ -z "$pci" ] || [ -z "$card" ] && continue
 
    vendor=$(lspci -s "$pci" 2>/dev/null)
    if echo "$vendor" | grep -qi "AMD\|ATI"; then
        AMD_CARD="/dev/dri/$card"
    elif echo "$vendor" | grep -qi "NVIDIA"; then
        NVIDIA_CARD="/dev/dri/$card"
    fi
done < <(ls -la /dev/dri/by-path/ | grep '\-card')
 
if [ -z "$AMD_CARD" ] || [ -z "$NVIDIA_CARD" ]; then
    err "Could not detect both GPU cards, skipping AQ_DRM_DEVICES update"
    err "AMD: ${AMD_CARD:-not found}, NVIDIA: ${NVIDIA_CARD:-not found}"
    warn "Manually set: env = AQ_DRM_DEVICES,/dev/dri/cardX:/dev/dri/cardY in hyprland.conf"
else
    AQ_VALUE="$AMD_CARD:$NVIDIA_CARD"
    log "Detected: AMD=$AMD_CARD NVIDIA=$NVIDIA_CARD"
    sed -i "s|env = AQ_DRM_DEVICES,.*|env = AQ_DRM_DEVICES,$AQ_VALUE|" "$HYPRLAND_CONF"
    ok "AQ_DRM_DEVICES updated to $AQ_VALUE"
fi
 
# ── Detect brightness device ───────────────────────────────────────────────────
log "Detecting brightness device..."
 
BL_DEVICE=$(brightnessctl --list | grep -oP 'amdgpu_bl\d+' | head -1)
 
if [ -z "$BL_DEVICE" ]; then
    err "Could not detect amdgpu brightness device, skipping"
    warn "Manually update brightnessctl -d <device> in hyprland.conf"
else
    log "Detected brightness device: $BL_DEVICE"
    sed -i "s|brightnessctl -d amdgpu_bl[^ ]*|brightnessctl -d $BL_DEVICE|g" "$HYPRLAND_CONF"
    ok "Brightness device updated to $BL_DEVICE"
fi
 
echo ""
ok "Services and dynamic config done"
echo ""
warn "Reboot to apply all changes:"
echo "  sync && reboot"
