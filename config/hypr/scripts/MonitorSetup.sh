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
    hyprctl eval "hl.monitor({ output = \"desc:$AOC_1\", mode = \"1920x1080@144\", position = \"1600x0\", scale = 1 })"
    hyprctl eval "hl.monitor({ output = \"desc:$AOC_2\", mode = \"1920x1080@60\", position = \"3520x0\", scale = 1 })"
elif [ "$HAS_AOC2" -eq 1 ]; then
    hyprctl eval "hl.monitor({ output = \"desc:$AOC_2\", mode = \"1920x1080@60\", position = \"1600x0\", scale = 1 })"
elif [ "$HAS_AOC1" -eq 1 ]; then
    hyprctl eval "hl.monitor({ output = \"desc:$AOC_1\", mode = \"1920x1080@144\", position = \"1600x0\", scale = 1 })"
fi
