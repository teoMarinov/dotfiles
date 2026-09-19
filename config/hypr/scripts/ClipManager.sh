#!/usr/bin/env bash

rofi_theme="$HOME/.config/rofi/clipboard.rasi"
msg="CTRL DEL = del (entry) or ALT DEl = wipe (all)"
thumb_dir="$HOME/.cache/cliphist/thumbnails"
mkdir -p "$thumb_dir"

if pidof rofi >/dev/null; then
  pkill rofi
fi

# drop thumbnails for entries that no longer exist
current_ids=$(cliphist list | cut -f1)
for f in "$thumb_dir"/*; do
  [[ -e "$f" ]] || continue
  id="${f##*/}"
  id="${id%%.*}"
  grep -qx "$id" <<<"$current_ids" || rm -f "$f"
done

build_list() {
  cliphist list | while IFS=$'\t' read -r id rest; do
    if [[ "$rest" == "[[ binary data"* ]]; then
      fmt=$(sed -nE 's/.*[KMG]iB ([a-zA-Z0-9]+) [0-9]+x[0-9]+.*/\1/p' <<<"$rest")
      [[ -z "$fmt" ]] && fmt="png"
      thumb="$thumb_dir/$id.$fmt"
      [[ -f "$thumb" ]] || printf '%s\t%s' "$id" "$rest" | cliphist decode >"$thumb" 2>/dev/null
      printf '%s\t%s\0icon\x1f%s\n' "$id" "$rest" "$thumb"
    else
      printf '%s\t%s\n' "$id" "$rest"
    fi
  done
}

while true; do
  result=$(
    build_list | rofi -i -dmenu -show-icons \
      -kb-custom-1 "Control-Delete" \
      -kb-custom-2 "Alt-Delete" \
      -config $rofi_theme \
      -mesg "$msg"
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
