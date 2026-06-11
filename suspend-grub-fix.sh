#!/bin/bash

# Legion Pro 5 16ADR10: S3 suspend instawake fix.
#
# Spurious edge interrupts on AMD GPIO controller AMDI0030:00 pins 2 and 4
# (wake IRQ 7, pinctrl_amd) wake the machine ~5s after entering S3. The pins
# sit below the ACPI wakeup layer, so /proc/acpi/wakeup toggles can't help.
# See https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2137024
#
# Masks the symptom, not the root cause — re-test without this after a BIOS
# update newer than RLCN29WW (RLCN32WW may fix it properly).

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}→${NC} $1"; }
ok()  { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

PARAM="gpiolib_acpi.ignore_interrupt=AMDI0030:00@2,AMDI0030:00@4"
GRUB_FILE="/etc/default/grub"

if grep -q "$PARAM" "$GRUB_FILE"; then
    ok "Suspend fix already present in $GRUB_FILE, skipping"
    exit 0
fi

log "Backing up $GRUB_FILE..."
sudo cp "$GRUB_FILE" "$GRUB_FILE.bak"

log "Adding $PARAM to GRUB_CMDLINE_LINUX_DEFAULT..."
sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s|\"$| $PARAM\"|" "$GRUB_FILE"

if ! grep -q "$PARAM" "$GRUB_FILE"; then
    warn "Failed to update GRUB_CMDLINE_LINUX_DEFAULT, restoring backup"
    sudo cp "$GRUB_FILE.bak" "$GRUB_FILE"
    exit 1
fi

log "Regenerating grub config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

ok "Suspend fix applied — takes effect after reboot"
