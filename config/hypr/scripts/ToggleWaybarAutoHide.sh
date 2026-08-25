#!/usr/bin/env bash
# Toggles WaybarAutoHide.sh on/off.
# Off -> waybar stays always visible. On -> hover the top edge to reveal it.

WATCHER="$HOME/.config/hypr/scripts/WaybarAutoHide.sh"

if pgrep -f "$WATCHER" >/dev/null; then
    pkill -f "$WATCHER"
    pkill -SIGUSR1 -x waybar
else
    pkill -SIGUSR2 -x waybar
    setsid "$WATCHER" >/tmp/waybar-autohide.log 2>&1 < /dev/null &
fi
