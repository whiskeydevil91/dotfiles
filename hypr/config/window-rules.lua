--------------------------------------------------------------------------------
--                               WINDOW RULES                                 --
--------------------------------------------------------------------------------
-- Per-application behavior: floating, size, monitor placement, layer effects.
-- Run `hyprctl clients` to find a window's class and title.
--
-- See: https://wiki.hypr.land/configuring/core/rules/window-rules/
--------------------------------------------------------------------------------

-- ─── General fixes ──────────────────────────────────────────────────────────
hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    -- Don't start the sleep timer while a game or video is fullscreen
    name         = "idle-inhibit-fullscreen",
    match        = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- ─── Steam ──────────────────────────────────────────────────────────────────
hl.window_rule({
    name   = "steam-size",
    match  = { class = "^(steam)$", title = "^(Steam)$" },
    float  = true,
    size   = { 1800, 1200 },
    center = true,
})

hl.window_rule({
    name   = "steam-settings",
    match  = { class = "^(steam)$", title = "^(Steam Settings)$" },
    float  = true,
    size   = { 800, 800 },
    center = true,
})

-- ─── Monitor assignments ────────────────────────────────────────────────────
hl.window_rule({
    -- Discord opens on the top monitor
    name    = "discord-assign",
    match   = { class = "^(discord)$" },
    monitor = "HDMI-A-1",
})

hl.window_rule({
    -- Zen browser opens on the main monitor
    name    = "zen-assign",
    match   = { class = "^(zen)$" },
    monitor = "DP-2",
})

-- ─── Layers ─────────────────────────────────────────────────────────────────
hl.layer_rule({
    name       = "rofi",
    match      = { namespace = "rofi" },
    blur       = true,
    dim_around = true,
})
