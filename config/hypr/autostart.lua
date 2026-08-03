-- Autostart (was configs/Startup_Apps.conf + the exec-once in hyprland.conf)
-- hl.on("hyprland.start", ...) runs once, on compositor startup (= exec-once).

hl.on("hyprland.start", function()
  hl.exec_cmd(configDir .. "/initial-boot.sh")

  hl.exec_cmd("waybar")
  hl.exec_cmd("awww-daemon")

  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("blueman-applet")

  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

  hl.exec_cmd("swaync")
  hl.exec_cmd("discord")
  hl.exec_cmd("hypridle")
end)
