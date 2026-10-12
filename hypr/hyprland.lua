--------------------------------------------------------------------------------
--                                                                            --
--                                 HYPRLAND                                   --
--                                                                            --
--------------------------------------------------------------------------------
-- Entry point for the Hyprland Lua config (Hyprland 0.55+).
--
-- Each require() below loads one file from ./config/. Hyprland runs every
-- required file in its own scope, so an error in one file does not stop the
-- others from loading. Shared values (programs, mainMod) live in
-- config/variables.lua and are returned as a table to the files that need them.
--
-- See: https://wiki.hypr.land/configuring/
--------------------------------------------------------------------------------

require("config.monitors")
require("config.environment")
require("config.aesthetics")
require("config.input")
require("config.autostart")
require("config.keybindings")
require("config.window-rules")

-- Written by scripts/nvidia.sh on NVIDIA systems; skipped when absent
pcall(require, "config.nvidia")
