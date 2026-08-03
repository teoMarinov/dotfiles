-- Window & layer rules (was configs/WindowRules.conf)
-- Rules are evaluated top to bottom; order matters.

hl.window_rule({
	name = "discord-position",
	match = { class = "^(discord)$" },
	-- monitor = "HDMI-A-1",
	workspace = "9 silent",
	focus_on_activate = true,
})

hl.window_rule({
	name = "steam-focus",
	match = { class = "^(steam)$" },
	focus_on_activate = true,
})

hl.window_rule({
	name = "file-float",
	match = { class = "^(org.gnome.Nautilus)$" },
	float = true,
	move = "225 60",
	-- center = true,
	size = "1100 900",
})

hl.window_rule({
	name = "loupe-image-viewer-float",
	match = { class = "^(org.gnome.Loupe)$" },
	float = true,
})

hl.window_rule({
	name = "calculator",
	match = { class = "^(org.gnome.Calculator)$" },
	float = true,
	size = "360 540",
})

-- Center the calculator on the cursor.
hl.window_rule({
	match = { class = "^(org.gnome.Calculator)$" },
	move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))",
})

hl.window_rule({
	name = "floating_kitty",
	match = { class = "(floating_shell)" },
	float = true,
	move = "385 135",
	size = "1150 840",
})

hl.window_rule({
	name = "pavucontrol_popup",
	match = { class = "^(pavucontrol)$" },
	float = true,
	move = "1200 40",
	size = "400 500",
})

hl.window_rule({
	name = "transparent_kitty",
	match = { class = "^(kitty)$" },
	opacity = "0.85",
})

hl.window_rule({
	name = "slack_allow_notification_focus",
	match = { class = "^(slack)$" },
	focus_on_activate = true,
})

hl.layer_rule({
	name = "rofi_no_animation",
	match = { namespace = "^(rofi)$" },
	no_anim = true,
})
