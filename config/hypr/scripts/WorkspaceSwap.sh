#!/bin/bash

CURRENT_WS_ID=$(hyprctl activeworkspace -j | jq -r '.id')
CURRENT_WS_NAME=$(hyprctl activeworkspace -j | jq -r '.name')
SPECIAL_NAME="special:shelf_$CURRENT_WS_NAME"

MAIN_ADDRS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $CURRENT_WS_ID and .pinned == false) | .address")
SHELF_ADDRS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$SPECIAL_NAME\") | .address")

for addr in $MAIN_ADDRS; do
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$SPECIAL_NAME\", window = \"address:$addr\", follow = false })"
done

for addr in $SHELF_ADDRS; do
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$CURRENT_WS_NAME\", window = \"address:$addr\", follow = false })"
done
