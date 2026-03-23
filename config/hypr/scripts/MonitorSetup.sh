#!/bin/bash

# Check which monitors are connected
MONITORS=$(hyprctl monitors -j | python3 -c "
import json, sys
monitors = json.load(sys.stdin)
for m in monitors:
    print(m)
")

AOC_1="AOC 24G1WG4 0x00035952"
AOC_2="AOC 2269WM AJCJ29A000729"

HAS_AOC1=$(echo "$MONITORS" | grep -c "$AOC_1")
HAS_AOC2=$(echo "$MONITORS" | grep -c "$AOC_2")

if [ "$HAS_AOC1" -eq 1 ] && [ "$HAS_AOC2" -eq 1 ]; then
    hyprctl keyword monitor "desc:$AOC_1,1920x1080@144,2048x0,1"
    hyprctl keyword monitor "desc:$AOC_2,1920x1080@60,3968x0,1"
elif [ "$HAS_AOC2" -eq 1 ]; then
    hyprctl keyword monitor "desc:$AOC_2,1920x1080@60,2048x0,1"
elif [ "$HAS_AOC1" -eq 1 ]; then
    hyprctl keyword monitor "desc:$AOC_1,1920x1080@144,2048x0,1"
fi
