#!/bin/bash
# Check wifi first
SSID=$(iwgetid -r 2>/dev/null)
if [ -n "$SSID" ]; then
    echo "󰤨  "
    exit 0
fi

# Check LAN
LAN=$(ip link show | grep -E "^[0-9]+: e" | grep "state UP" | head -1 | awk '{print $2}' | tr -d ':')
if [ -n "$LAN" ]; then
    echo "󰈀  "
    exit 0
fi

echo "󰤭  "
