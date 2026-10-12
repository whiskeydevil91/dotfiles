--------------------------------------------------------------------------------
--                                 AUTOSTART                                  --
--------------------------------------------------------------------------------
-- Processes launched once when Hyprland starts.
-- hl.exec_cmd() runs commands in the background, so no trailing `&` is needed.
--
-- See: https://wiki.hypr.land/configuring/core/autostart/
--------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    -- ── System services ────────────────────────────────────────────────────
    hl.exec_cmd("xwaylandvideobridge")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- ── Desktop ────────────────────────────────────────────────────────────
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css")
    hl.exec_cmd("swaync")
end)
