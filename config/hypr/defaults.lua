-- App defaults (was configs/Defaults.conf)
-- This file was sourced from Keybinds.conf in the old config. It exports the
-- handful of "$variables" the rest of the config referenced.

hl.env("EDITOR", "nvim")

local defaults = {
  edit          = os.getenv("EDITOR") or "nvim",          -- $edit = ${EDITOR:-nvim}
  term          = "kitty",                                 -- $term
  files         = "nautilus",                              -- $files
  -- $Search_Engine was defined but never used; the "google.con" typo is from
  -- the original config and kept verbatim.
  search_engine = "https://www.google.con/search?q={}",
}

return defaults
