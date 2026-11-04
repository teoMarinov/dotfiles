#!/usr/bin/env bash
# Alt-Tab style window switcher for Hyprland, with live window previews.
# Hold SUPER, tap Tab / Shift+Tab (or Left/Right) to cycle in most-recently-used
# order, release SUPER to switch. Escape cancels, Enter / click also switches.
#
# The Hyprland bind must be non_consuming so that repeated SUPER+Tab presses
# reach rofi while it is open; those repeats re-run this script, hence the guard.

pidof -q rofi && exit 0

theme="$HOME/.config/rofi/window-switcher.rasi"
thumbs="${XDG_RUNTIME_DIR:-/tmp}/rofi-window-switcher"
thumb_width=480 # capture width in px; the card size itself is set in the theme
max_columns=5
card_width=290 # element-icon size + 2 * element padding + listview spacing in the theme

mkdir -p "$thumbs"
rm -f "$thumbs"/*.jpg

# Resolve a window class to an icon name via its .desktop file (falls back to the class).
icon_for() {
	local class=$1 file icon
	file=$(find /usr/share/applications ~/.local/share/applications /var/lib/flatpak/exports/share/applications \
		-maxdepth 1 -iname "$class.desktop" -print -quit 2>/dev/null)
	[[ -z $file ]] && file=$(grep -lisx "StartupWMClass=$class" \
		/usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null | head -n1)
	[[ -n $file ]] && icon=$(grep -m1 '^Icon=' "$file" | cut -d= -f2-)
	echo "${icon:-${class,,}}"
}

mapfile -t windows < <(hyprctl clients -j | jq -r '
	def esc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;") | gsub("\t"; " ");
	map(select(.mapped and (.hidden | not))) | sort_by(.focusHistoryID)[]
	| [.address, .stableId, .size[0], (.class | esc), (.title | esc)] | @tsv')

((${#windows[@]})) || exit 0

# Capture every window in parallel (works for windows on other workspaces too).
for window in "${windows[@]}"; do
	IFS=$'\t' read -r _ id width _ <<<"$window"
	grim -T "$id" -s "$(bc -l <<<"$thumb_width / $width")" -t jpeg -q 85 "$thumbs/$id.jpg" 2>/dev/null &
done
wait

count=${#windows[@]}
columns=$((count < max_columns ? count : max_columns))
lines=$(((count + columns - 1) / columns))

index=$(
	for window in "${windows[@]}"; do
		IFS=$'\t' read -r _ id _ class title <<<"$window"
		icon="$thumbs/$id.jpg"
		[[ -s $icon ]] || icon=$(icon_for "$class")
		printf '<b>%s</b>  %s\0icon\x1f%s\n' "$class" "$title" "$icon"
	done | rofi -dmenu -i -p "Windows" -theme "$theme" \
		-theme-str "window { width: $((columns * card_width + 10))px; } listview { columns: $columns; lines: $lines; }" \
		-show-icons -markup-rows -format i -selected-row 1 \
		-kb-accept-entry "!Super_L,!Super+Super_L,!Super_R,!Super+Super_R,Return,KP_Enter" \
		-kb-element-next "Super+Tab,Tab,Right" \
		-kb-element-prev "Super+ISO_Left_Tab,Super+Shift+ISO_Left_Tab,ISO_Left_Tab,Left" \
		-kb-move-char-back "Control+b" -kb-move-char-forward "Control+f"
)

[[ -n $index ]] && hyprctl dispatch "hl.dsp.focus({ window = \"address:${windows[$index]%%$'\t'*}\" })" >/dev/null
