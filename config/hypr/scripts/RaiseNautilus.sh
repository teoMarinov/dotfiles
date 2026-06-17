#!/bin/bash

CLASS="org.gnome.Nautilus"

if hyprctl clients | grep -q "class: $CLASS"; then
  WS=$(hyprctl activeworkspace -j | jq -r '.name')
  hyprctl dispatch "hl.dsp.window.move({ workspace = \"$WS\", window = \"class:$CLASS\" })"
  hyprctl dispatch "hl.dsp.focus({ window = \"class:$CLASS\" })"
else
  nautilus
fi
