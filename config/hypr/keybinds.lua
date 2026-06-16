-- Keybindings (was configs/Keybinds.conf)

local defaults   = require("defaults")
local mod        = "SUPER"
local scriptsDir = configDir .. "/scripts"

-- ──────────────────────────────────────────────────────────────────────────
-- The original Keybinds.conf opened with the stock ML4W example binds, but they
-- were all collapsed onto one physical line after a `#`, so hyprlang treated
-- them as a comment (i.e. they were never active). They are reproduced here as
-- comments only, to match current behaviour. Note most are also overridden by
-- the real binds below and reference undefined vars ($terminal/$filemanager/$menu).
--
--   SUPER + Q  -> exec $terminal          SUPER + C -> killactive
--   SUPER + M  -> exit                    SUPER + E -> exec $filemanager
--   SUPER + V  -> togglefloating          SUPER + R -> exec $menu
--   SUPER + P  -> pseudo (dwindle)        SUPER + J -> layoutmsg togglesplit
-- ──────────────────────────────────────────────────────────────────────────

-- ── System / menus ─────────────────────────────────────────────────────────
hl.bind(mod .. " + A",          hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + B",          hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + Return",     hl.dsp.exec_cmd(defaults.term))
hl.bind(mod .. " + E",          hl.dsp.exec_cmd(scriptsDir .. "/RaiseNautilus.sh"))

-- Features / extras
hl.bind(mod .. " + SHIFT + E",  hl.dsp.exec_cmd(scriptsDir .. "/EmojiManager.sh"))
hl.bind(mod .. " + CTRL + S",   hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mod .. " + V",          hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"))
hl.bind(mod .. " + W",          hl.dsp.exec_cmd(scriptsDir .. "/WallpaperManager.sh"))
hl.bind(mod .. " + CTRL + W",   hl.dsp.exec_cmd(scriptsDir .. "/RandomWallpaper.sh"))
hl.bind(mod .. " + CTRL + T",   hl.dsp.exec_cmd(scriptsDir .. "/ToggleTouchpad.sh"))
hl.bind(mod .. " + R",          hl.dsp.exec_cmd(scriptsDir .. "/MonitorSetup.sh"))
hl.bind(mod .. " + ESCAPE",     hl.dsp.exec_cmd(scriptsDir .. "/PowerMenu.sh"))
hl.bind(mod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + N",          hl.dsp.exec_cmd("swaync-client -t")) -- toggle panel
hl.bind(mod .. " + SHIFT + N",  hl.dsp.exec_cmd("swaync-client -d")) -- toggle do not disturb

hl.bind(mod .. " + F",          hl.dsp.window.fullscreen())
hl.bind(mod .. " + SPACE",      hl.dsp.window.fullscreen({ mode = 1 })) -- maximize window
hl.bind(mod .. " + SHIFT + F",  hl.dsp.window.float())
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd(scriptsDir .. "/Dropterminal.sh " .. defaults.term))

-- Desktop zooming (double / halve the cursor zoom factor)
hl.bind(mod .. " + ALT + mouse_down",
  hl.dsp.exec_cmd([[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')"]]))
hl.bind("SHIFT_L + ALT_L",      hl.dsp.exec_cmd(scriptsDir .. "/SwitchKeyboardLayout.sh"))

-- ── System control ─────────────────────────────────────────────────────────
hl.bind("CTRL + ALT + Delete",  hl.dsp.exit())
hl.bind(mod .. " + Q",          hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q",  hl.dsp.exec_cmd(scriptsDir .. "/KillActiveProcess.sh"))

hl.bind(mod .. " + Print",          hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"))
hl.bind(mod .. " + CTRL + Print",   hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"))
hl.bind(mod .. " + SHIFT + Print",  hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"))
hl.bind("Print",                    hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --swappy"))

-- ── Navigation ─────────────────────────────────────────────────────────────
-- key -> direction, for arrows and vim keys (h=left, l=right, k=up, j=down)
local dirs = {
  { "left", "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" },
  { "h",    "l" }, { "l",     "r" }, { "k",  "u" }, { "j",    "d" },
}
-- key -> (dx, dy) sign, for resize/move deltas
local deltas = {
  { "left", -1, 0 }, { "right", 1, 0 }, { "up", 0, -1 }, { "down", 0, 1 },
  { "h",    -1, 0 }, { "l",     1, 0 }, { "k",  0, -1 }, { "j",    0, 1 },
}

-- Focus movement
for _, d in ipairs(dirs) do
  hl.bind(mod .. " + " .. d[1], hl.dsp.focus({ direction = d[2] }))
end

-- Move window
for _, d in ipairs(dirs) do
  hl.bind(mod .. " + ALT + " .. d[1], hl.dsp.window.move({ direction = d[2] }))
end
hl.bind(mod .. " + period", hl.dsp.layout("swapcol r"))
hl.bind(mod .. " + comma",  hl.dsp.layout("swapcol l"))

-- Resize window (repeatable)
for _, d in ipairs(deltas) do
  hl.bind(mod .. " + SHIFT + " .. d[1],
    hl.dsp.window.resize({ x = d[2] * 50, y = d[3] * 50, relative = true }), { repeating = true })
end

-- Move floating window (repeatable)
for _, d in ipairs(deltas) do
  hl.bind(mod .. " + CTRL + SHIFT + " .. d[1],
    hl.dsp.window.move({ x = d[2] * 40, y = d[3] * 40, relative = true }), { repeating = true })
end

-- Move current workspace to another monitor
for _, d in ipairs(dirs) do
  hl.bind(mod .. " + CTRL + ALT + " .. d[1], hl.dsp.workspace.move({ monitor = d[2] }))
end

-- ── Workspaces ─────────────────────────────────────────────────────────────
-- code:10 = key "1" ... code:18 = key "9"; grave = workspace 10
for i = 1, 9 do
  hl.bind(mod .. " + code:" .. (9 + i),         hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + CTRL + code:" .. (9 + i),  hl.dsp.window.move({ workspace = i }))
  hl.bind(mod .. " + SHIFT + code:" .. (9 + i), hl.dsp.window.move({ workspace = i, silent = true }))
end

hl.bind(mod .. " + grave",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mod .. " + CTRL + grave",  hl.dsp.window.move({ workspace = 10 }))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = 10, silent = true }))

-- Move to adjacent workspace
hl.bind(mod .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mod .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mod .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "-1", silent = true }))
hl.bind(mod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1", silent = true }))

-- Layout switching (was: hyprctl keyword general:layout ...)
hl.bind(mod .. " + P",         function() hl.config({ general = { layout = "master" } }) end)
hl.bind(mod .. " + SHIFT + P", function() hl.config({ general = { layout = "dwindle" } }) end)
hl.bind(mod .. " + CTRL + P",  function() hl.config({ general = { layout = "scrolling" } }) end)

-- ── Special workspace ──────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mod .. " + U",         hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + S",         hl.dsp.exec_cmd(scriptsDir .. "/WorkspaceSwap.sh"))

-- ── Mouse binds ────────────────────────────────────────────────────────────
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── App quickstart ─────────────────────────────────────────────────────────
hl.bind(mod .. " + D",         hl.dsp.exec_cmd("discord"))
hl.bind(mod .. " + O",         hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + G",         hl.dsp.exec_cmd("steam"))
hl.bind(mod .. " + I",         hl.dsp.exec_cmd("an-anime-game-launcher"))
hl.bind(mod .. " + equal",     hl.dsp.exec_cmd("kate"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))
