#!/usr/bin/env bash
# Lightshot-style screenshot (bound to Print in keybinds.lua):
#   1. freeze every monitor on the current frame   (hyprpicker)
#   2. drag to select an area — Esc cancels        (slurp)
#   3. grab that area from the frozen frame        (grim)
#   4. draw on it, then copy / save                (satty, see ~/.config/satty/config.toml)

set -u

dir="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$dir"

tmp=$(mktemp --suffix=.png)
freeze_pid=
cleanup() {
	[[ -n $freeze_pid ]] && kill "$freeze_pid" 2>/dev/null
	rm -f "$tmp"
}
trap cleanup EXIT

# Ignore repeat presses while a selection is already on screen
# (the lock is released before satty opens, so a new shot can start then).
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/screenshot.lock"
flock -n 9 || exit 0

# 1. Freeze. hyprpicker needs a moment to put the still frame up.
hyprpicker --render-inactive --no-zoom --quiet >/dev/null 2>&1 &
freeze_pid=$!
sleep 0.2

# 2. Select: dim outside the selection, clear inside, show dimensions.
geom=$(slurp -d -b '#00000077' -s '#00000000' -c '#ffffffff' -w 1) || exit 0
[[ -n $geom ]] || exit 0

# 3. Capture (still frozen, so this is the frame from when Print was pressed).
grim -g "$geom" "$tmp" || exit 1
kill "$freeze_pid" 2>/dev/null
freeze_pid=
exec 9>&-

# grim captures at the monitor's pixel scale; tell satty so the window shows
# the crop at the size it had on screen (eDP-2 is 1.6x).
read -r x y _ <<<"${geom//,/ }"
scale=$(hyprctl monitors -j | jq -r --argjson x "$x" --argjson y "$y" '
	[.[] | select($x >= .x and $x < .x + .width / .scale
	          and $y >= .y and $y < .y + .height / .scale) | .scale][0] // 1')

# 4. Annotate. Enter/Ctrl+C copies, Ctrl+S saves, Esc discards.
satty --filename "$tmp" --input-scale "$scale"
