#!/usr/bin/env bash

rofi_theme="$HOME/.config/rofi/clipboard.rasi"
msg="CTRL DEL = del (entry) or ALT DEl = wipe (all)"

if pidof rofi >/dev/null; then
  pkill rofi
fi

while true; do
  result=$(
    rofi -i -dmenu \
      -kb-custom-1 "Control-Delete" \
      -kb-custom-2 "Alt-Delete" \
      -config $rofi_theme \
      -mesg "$msg" < <(cliphist list)
  )

  case "$?" in
  1)
    exit
    ;;
  0)
    case "$result" in
    "")
      continue
      ;;
    *)
      cliphist decode <<<"$result" | wl-copy
      exit
      ;;
    esac
    ;;
  10)
    cliphist delete <<<"$result"
    ;;
  11)
    cliphist wipe
    ;;
  esac
done
