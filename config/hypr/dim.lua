-- Global software dim via wl-gammarelay-rs.
--
-- This started life as a decoration:screen_shader, which dims inside
-- Hyprland's render pass. That flickered under partial damage tracking (only
-- damaged regions get re-shaded) and it also dimmed screenshots and screen
-- shares. wl-gammarelay-rs writes the CRTC gamma ramp instead, via
-- zwlr_gamma_control_v1, which is applied after compositing: no render cost,
-- no damage-tracking interaction, and captures stay at full brightness.
--
-- Requires wl-gammarelay-rs (AUR). It is D-Bus activated, so nothing has to
-- autostart it -- the first busctl call brings it up.
--
-- Covers every monitor at once. HDMI-A-1 is already at DDC brightness 0 and
-- DP-1 answers no DDC at all, so neither has hardware headroom left; eDP-2
-- keeps its real backlight on the bare XF86MonBrightness keys (ctl.lua).

local M = {}

local MIN, MAX, STEP = 10, 100, 5

local stateFile = os.getenv("HOME") .. "/.cache/hypr-dim-level"
local SET_BRIGHTNESS = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d %.2f"
local NOTIFY = "notify-send -i display-brightness"
	.. " -h string:x-canonical-private-synchronous:hypr-dim 'Screen dim' '%d%%'"

local function clamp(level)
	level = math.floor((tonumber(level) or MAX) + 0.5)
	if level < MIN then
		return MIN
	elseif level > MAX then
		return MAX
	end
	return level
end

function M.set(level, notify)
	level = clamp(level)
	hl.exec_cmd(string.format(SET_BRIGHTNESS, level / 100))
	M.level = level

	local f = io.open(stateFile, "w")
	if f then
		f:write(tostring(level))
		f:close()
	end

	if notify then
		hl.exec_cmd(string.format(NOTIFY, level))
	end
	return level
end

function M.step(delta)
	return M.set((M.level or MAX) + delta, true)
end

M.STEP = STEP

-- Remember the level across reloads; the daemon keeps it live within a
-- session, so it only needs re-applying once the compositor comes up.
local saved = io.open(stateFile, "r")
M.level = saved and (tonumber(saved:read("l")) or MAX) or MAX
if saved then
	saved:close()
end

hl.on("hyprland.start", function()
	if M.level < MAX then
		M.set(M.level)
	end
end)

return M
