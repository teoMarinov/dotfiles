if uwsm check may-start; then
  exec uwsm start hyprland.desktop
fi

# Theme settings for consistent dark mode
export GTK_THEME=Flat-Remix-GTK-Blue-Darkest
export QT_STYLE_OVERRIDE=fusion
export QT_QPA_PLATFORMTHEME=qt6ct

# Added by Toolbox App
export PATH="$PATH:/home/teo/.local/share/JetBrains/Toolbox/scripts"

