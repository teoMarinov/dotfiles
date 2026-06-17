#!/bin/bash

LOCK="󰌾  Lock"
SHUTDOWN="󰐥  Shutdown"
REBOOT="󰑓  Reboot"
SUSPEND="󰤄  Sleep"
LOGOUT="󰍃  Logout"

chosen=$(printf "%s\n" "$LOCK" "$SHUTDOWN" "$REBOOT" "$SUSPEND" "$LOGOUT" \
    | rofi -dmenu \
           -config ~/.config/rofi/power-menu.rasi \
           -p "" \
           -no-custom \
           -kb-row-select "1" \
           -kb-accept-entry "Return,KP_Enter" \
           -selected-row 0)

case "$chosen" in
    "$LOCK")        hyprlock ;;
    "$SHUTDOWN")    systemctl poweroff ;;
    "$REBOOT")      systemctl reboot ;;
    "$SUSPEND")     systemctl suspend ;;
    "$LOGOUT")      hyprctl dispatch 'hl.dsp.exit()' ;;
esac
