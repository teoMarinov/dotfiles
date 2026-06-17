#!/usr/bin/env bash

DEV="gxtp5100:00-27c6:01e0-touchpad"
STATE_FILE="$HOME/.cache/touchpad_disabled"
iDIR="$HOME/.config/swaync/images"

if [[ -f "$STATE_FILE" ]]; then
  hyprctl eval "hl.device({ name = \"$DEV\", enabled = true })" >/dev/null
  rm -f "$STATE_FILE"
  notify-send -i "$iDIR/info.png" "Touchpad" "Enabled"
else
  hyprctl eval "hl.device({ name = \"$DEV\", enabled = false })" >/dev/null
  touch "$STATE_FILE"
  notify-send -i "$iDIR/info.png" "Touchpad" "Disabled"
fi
