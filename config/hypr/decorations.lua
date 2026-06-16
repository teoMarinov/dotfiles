-- Decorations (was configs/Decorations.conf)
-- Borders/gaps live under general; everything else under decoration.

hl.config({
  general = {
    border_size = 1,
    gaps_in  = 3,
    gaps_out = 5,

    -- col.active_border = rgba(ddddddcc) rgba(dddddd66) 90deg
    col = {
      active_border = { colors = { "rgba(ddddddcc)", "rgba(dddddd66)" }, angle = 90 },
    },
  },

  decoration = {
    rounding = 0,

    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    dim_inactive = false,
    dim_strength = 0.1,
    dim_special = 0.8,

    shadow = {
      enabled = true,
      range = 60,
      render_power = 20,
      color = "rgba(00000050)",
    },

    blur = {
      enabled = true,
      size = 5,
      passes = 1,
      ignore_opacity = false,
      new_optimizations = true,
      special = true,
      popups = true,
    },
  },
})
