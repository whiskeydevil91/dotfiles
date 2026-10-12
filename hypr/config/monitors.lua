--------------------------------------------------------------------------------
--                                 MONITORS                                   --
--------------------------------------------------------------------------------
-- Resolution, refresh rate, position and scale for each display.
-- Run `hyprctl monitors all` to list monitor names.
--
-- See: https://wiki.hypr.land/configuring/core/monitors/
--------------------------------------------------------------------------------

-- TOP monitor (secondary)
hl.monitor({ output = "HDMI-A-1", mode = "2560x1080@60", position = "0x0",    scale = 1 })

-- BOTTOM monitor (main)
hl.monitor({ output = "DP-2",     mode = "3440x1440@60", position = "0x1080", scale = 1 })

-- Any other monitor: preferred mode, placed automatically
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
