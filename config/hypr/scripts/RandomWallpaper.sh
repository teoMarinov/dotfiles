#!/usr/bin/env bash

wallDIR="$HOME/Pictures/Wallpapers/"
iDIR="$HOME/.config/swaync/images"

FPS=60
TYPE="any"
DURATION=0.5
AWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
if [[ -z "$focused_monitor" ]]; then
  notify-send -i "$iDIR/error.png" "RandomWallpaper" "Could not detect focused monitor"
  exit 1
fi

mapfile -d '' PICS < <(find -L "$wallDIR" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) -print0)

if [[ ${#PICS[@]} -eq 0 ]]; then
  notify-send -i "$iDIR/error.png" "RandomWallpaper" "No images found in $wallDIR"
  exit 1
fi

current_link="$HOME/.cache/current_wallpaper_${focused_monitor}.png"
current_target=""
[[ -L "$current_link" ]] && current_target=$(readlink -f "$current_link")

# Pick a random one, avoiding the current wallpaper if more than one is available
selected="$current_target"
if [[ ${#PICS[@]} -gt 1 ]]; then
  while [[ "$selected" == "$current_target" ]]; do
    selected="${PICS[RANDOM % ${#PICS[@]}]}"
  done
else
  selected="${PICS[0]}"
fi

if ! pgrep -x "awww-daemon" >/dev/null; then
  awww-daemon --format xrgb &
  sleep 0.3
fi

awww img -o "$focused_monitor" "$selected" $AWWW_PARAMS

ln -sf "$selected" "$HOME/.cache/current_wallpaper_${focused_monitor}.png"
ln -sf "$selected" "$HOME/.cache/current_wallpaper.png"

while IFS= read -r mon; do
  [[ -z "$mon" || "$mon" == "$focused_monitor" ]] && continue
  [[ -e "$HOME/.cache/current_wallpaper_${mon}.png" ]] && continue
  ln -sf "$selected" "$HOME/.cache/current_wallpaper_${mon}.png"
done < <(hyprctl monitors -j | jq -r '.[].name')
