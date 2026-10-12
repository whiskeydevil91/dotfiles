--------------------------------------------------------------------------------
--                                KEYBINDINGS                                 --
--------------------------------------------------------------------------------
-- Every bind carries a description, so `hyprctl binds` (and the SUPER + /
-- cheat sheet) can list them.
--
-- See: https://wiki.hypr.land/configuring/core/binds/
--      https://wiki.hypr.land/configuring/core/dispatchers/
--------------------------------------------------------------------------------

local vars    = require("config.variables")
local mainMod = vars.mainMod

-- Bind helper: hl.bind() with a description, plus any extra flags
local function bind(keys, action, description, flags)
    flags = flags or {}
    flags.description = description
    return hl.bind(keys, action, flags)
end

local exec = hl.dsp.exec_cmd

-- ─── Help ───────────────────────────────────────────────────────────────────
bind(mainMod .. " + slash", exec("~/.config/hypr/scripts/show-keybindings.sh"), "Show keybindings")
bind(mainMod .. " + F1",    exec("~/.config/hypr/scripts/show-keybindings.sh"), "Show keybindings")

-- ─── Applications ───────────────────────────────────────────────────────────
bind(mainMod .. " + Return", exec(vars.terminal),              "Terminal")
bind(mainMod .. " + SPACE",  exec(vars.menu),                  "App launcher")
bind(mainMod .. " + W",      exec(vars.browser),               "Browser")
bind(mainMod .. " + E",      exec(vars.fileManager),           "File manager")
bind(mainMod .. " + Y",      exec(vars.terminal .. " -e yazi"), "Yazi file manager")
bind(mainMod .. " + T",      exec(vars.editor),                "Code editor")
bind(mainMod .. " + D",      exec("discord"),                  "Discord")
bind(mainMod .. " + minus",  exec(vars.terminal .. " --title dashboard -e ~/.local/bin/dashboard-tmux"), "Dashboard")

-- ─── Session ────────────────────────────────────────────────────────────────
bind(mainMod .. " + L", exec("loginctl lock-session"), "Lock screen")
bind(mainMod .. " + DELETE",
    exec("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
    "Exit Hyprland")

-- ─── Windows ────────────────────────────────────────────────────────────────
bind(mainMod .. " + Q", hl.dsp.window.close(),                       "Close window")
bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }),  "Toggle floating")
bind("ALT + F",         hl.dsp.window.fullscreen({ action = "toggle" }), "Toggle fullscreen")
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"),                "Toggle split (dwindle)")

-- Switch between the master and dwindle layouts
bind(mainMod .. " + ALT + SPACE", function()
    if hl.get_config("general.layout") == "dwindle" then
        hl.config({ ["general.layout"] = "master" })
    else
        hl.config({ ["general.layout"] = "dwindle" })
    end
end, "Switch master / dwindle layout")

-- Focus and move with arrow keys
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind(mainMod .. " + " .. dir,         hl.dsp.focus({ direction = dir }),       "Focus " .. dir)
    bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }), "Move window " .. dir)
end

-- Move/resize with SUPER + left/right mouse drag
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   "Drag window",   { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- ─── Workspaces ─────────────────────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       "Go to workspace " .. i)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end

-- Scratchpad
bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),            "Toggle scratchpad")
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), "Move window to scratchpad")

-- Scroll through workspaces with SUPER + mouse wheel
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

-- ─── Screenshots ────────────────────────────────────────────────────────────
bind("Print",           exec("hyprshot -m region"),                  "Screenshot region")
bind("SHIFT + Print",   exec("hyprshot -m window"),                  "Screenshot window")
bind("CTRL + Print",    exec("hyprshot -m output"),                  "Screenshot monitor")
bind(mainMod .. " + P", exec("hyprshot -m region --clipboard-only"), "Screenshot region to clipboard")

-- ─── Media keys (work on the lock screen too) ───────────────────────────────
local held = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Volume up",       held)
bind("XF86AudioLowerVolume",  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      "Volume down",     held)
bind("XF86AudioMute",         exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     "Mute",            held)
bind("XF86AudioMicMute",      exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   "Mute microphone", held)
bind("XF86MonBrightnessUp",   exec("brightnessctl -e4 -n2 set 5%+"),                  "Brightness up",   held)
bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"),                  "Brightness down", held)

bind("XF86AudioNext",  exec("playerctl next"),       "Next track",     { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), "Play / pause",   { locked = true })
bind("XF86AudioPlay",  exec("playerctl play-pause"), "Play / pause",   { locked = true })
bind("XF86AudioPrev",  exec("playerctl previous"),   "Previous track", { locked = true })
