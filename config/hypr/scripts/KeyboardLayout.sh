#!/bin/bash
hyprctl devices -j | python3 -c "
import json, sys
devices = json.load(sys.stdin)
for kb in devices.get('keyboards', []):
    if kb.get('main'):
        print(kb['active_keymap'][:2].upper())
        break
"
