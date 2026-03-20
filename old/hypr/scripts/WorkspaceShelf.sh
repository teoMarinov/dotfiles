#!/bin/bash

# 1. Get current workspace ID and name
# We use 'name' to support both numbered and named workspaces
CURRENT_WS_ID=$(hyprctl activeworkspace -j | jq -r '.id')
CURRENT_WS_NAME=$(hyprctl activeworkspace -j | jq -r '.name')
SPECIAL_NAME="special:shelf_$CURRENT_WS_NAME"

WINDOW_COUNT=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $CURRENT_WS_ID) and .pinned == false] | length")

if [ "$WINDOW_COUNT" -gt 0 ]; then
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $CURRENT_WS_ID) | .address" | while read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$SPECIAL_NAME,address:$addr"
    done
else
    # --- ACTION: RESTORE ---
    # Check if the "shelf" has windows to bring back
    SHELF_COUNT=$(hyprctl clients -j | jq -r "[.[] | select(.workspace.name == \"$SPECIAL_NAME\")] | length")
    
    if [ "$SHELF_COUNT" -gt 0 ]; then
        hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$SPECIAL_NAME\") | .address" | while read -r addr; do
            hyprctl dispatch movetoworkspacesilent "$CURRENT_WS_NAME,address:$addr"
        done
    fi
fi
