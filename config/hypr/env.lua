-- Environment variables (was configs/ENVariables.conf)

hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "fusion")
hl.env("QT_LOGGING_RULES", "org.kde.kdeclarative.binding=false")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto") -- auto selects Wayland if possible, X11 otherwise

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GSK_RENDERER", "ngl")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GL_GSYNC_ALLOWED", "1")

hl.env("AQ_DRM_DEVICES", "/dev/dri/card2:/dev/dri/card1")
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card2:/dev/dri/card1")

hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
