-- Hyprland Lua configuration
-- Converted from the previous hyprlang (.conf) config on 2026-06-16.
-- Requires Hyprland >= 0.55 (you are on 0.55.4).
-- Docs: https://wiki.hypr.land/Configuring/  &  https://hypr.land/news/26_lua/
--
-- NOTE: While this hyprland.lua exists, Hyprland ignores hyprland.conf and
-- everything it sourced (monitors.conf, configs/*.conf). Those files are left
-- in place as an untouched backup. hyprlock/hypridle keep their own .conf files
-- (they are separate programs and are not affected by this migration).

-- Base config dir, used to build absolute paths to scripts.
configDir = os.getenv("HOME") .. "/.config/hypr"

require("monitors")          -- Monitor layout (was monitors.conf)
require("defaults")          -- EDITOR env + app defaults (was configs/Defaults.conf)
require("env")               -- Environment variables (was configs/ENVariables.conf)
require("system-settings")   -- input, misc, layouts, cursor, ... (was configs/SystemSettings.conf)
require("decorations")       -- borders/gaps + blur/shadow/rounding (was configs/Decorations.conf)
require("animations")        -- bezier curves + animations (was configs/Animations.conf)
require("window-rules")      -- window + layer rules (was configs/WindowRules.conf)
require("workspace-rules")   -- workspace -> monitor assignments (was configs/WorkSpaceRules.conf)
require("keybinds")          -- keybindings (was configs/Keybinds.conf)
require("ctl")               -- multimedia / brightness keys (was configs/CTL.conf)
require("autostart")         -- startup apps (was configs/Startup_Apps.conf + initial-boot.sh)
