--------------------------------------------------------------------------------
--                           ENVIRONMENT VARIABLES                            --
--------------------------------------------------------------------------------
-- Set before the session starts, so apps launched by Hyprland inherit them.
--
-- See: https://wiki.hypr.land/configuring/core/environment-variables/
--------------------------------------------------------------------------------

-- Theming
hl.env("GTK_THEME", "Nordic-Darker")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- Cursor
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
