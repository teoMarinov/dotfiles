#!/bin/bash

CLASS="org.gnome.Nautilus"

if hyprctl clients | grep -q "class: $CLASS"; then
  hyprctl dispatch movetoworkspace current,class:$CLASS
  hyprctl dispatch focuswindow class:$CLASS
else
  nautilus
fi
