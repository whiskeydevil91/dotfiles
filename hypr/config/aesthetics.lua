--------------------------------------------------------------------------------
--                                AESTHETICS                                  --
--------------------------------------------------------------------------------
-- Gaps, borders, transparency, blur, shadows, animations and layouts.
--
-- See: https://wiki.hypr.land/configuring/core/config-options/
--      https://wiki.hypr.land/configuring/core/animations/
--------------------------------------------------------------------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 3,

        -- Neon magenta → pink gradient on the focused window
        col = {
            active_border   = { colors = { "rgba(ff00ffff)", "rgba(ff1493ff)" }, angle = 45 },
            inactive_border = "rgba(8b008baa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "master",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 0.75,
        inactive_opacity = 0.65,

        -- Magenta glow around windows
        shadow = {
            enabled      = true,
            range        = 40,
            render_power = 5,
            color        = "rgba(ff00ff44)",
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,
            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        allow_small_split    = true,
        special_scale_factor = 0.95,
        mfact                = 0.65,
        new_on_top           = false,
        new_on_active        = "none",
        new_status           = "slave",
        orientation          = "left",
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        -- The wallpaper comes from scripts/wallpaper.sh
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- ─── Curves ─────────────────────────────────────────────────────────────────
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

-- ─── Animations ─────────────────────────────────────────────────────────────
hl.animation({ leaf = "global",        enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.2, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2.5, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.2, bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.5, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1,   bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.5, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 6,   bezier = "quick" })
