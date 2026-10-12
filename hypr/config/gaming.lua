--------------------------------------------------------------------------------
--                                  GAMING                                    --
--------------------------------------------------------------------------------
-- Steam games: solid (no transparency/blur), tearing for lower input lag,
-- VRR when fullscreen, and a SUPER + G "game mode" that strips effects.
--
-- In Steam, set each game's launch options to:
--     gamemoderun mangohud %command%
-- (gamemode = CPU/GPU performance mode, mangohud = FPS overlay)
--
-- See: https://wiki.hypr.land/configuring/extra/tearing/
--------------------------------------------------------------------------------

local vars = require("config.variables")

-- Proton games show up as steam_app_<id>; gamescope wraps games in its own window
local steamGames = "^(steam_app_.*|gamescope)$"

-- ─── Tearing + VRR ──────────────────────────────────────────────────────────
hl.config({
    general = {
        -- Only windows with `immediate = true` (games, below) actually tear
        allow_tearing = true,
    },
    misc = {
        -- Variable refresh rate (FreeSync / G-Sync) for fullscreen windows only
        vrr = 2,
    },
})

-- ─── Game windows ───────────────────────────────────────────────────────────
hl.window_rule({
    name      = "steam-games",
    match     = { class = steamGames },
    -- Fully opaque whether focused, unfocused or fullscreen
    opacity   = "1.0 override 1.0 override 1.0 override",
    no_blur   = true,
    no_shadow = true,
    no_dim    = true,
    immediate = true,
    content   = "game",
    -- Games open on workspace 5, which lives on the main monitor
    workspace = "5",
})

hl.window_rule({
    -- Any game that marks itself as a game gets the same treatment
    name      = "game-content",
    match     = { content = "game" },
    opacity   = "1.0 override 1.0 override 1.0 override",
    no_blur   = true,
    immediate = true,
})

hl.workspace_rule({ workspace = "5", monitor = "DP-2" })

-- ─── Game mode (SUPER + G) ──────────────────────────────────────────────────
-- Turns off animations, blur, shadows, gaps and transparency for every
-- window. Press again to restore the neon look.
local gameMode = false

hl.bind(vars.mainMod .. " + G", function()
    gameMode = not gameMode

    if gameMode then
        hl.config({
            ["animations.enabled"]          = false,
            ["decoration.blur.enabled"]     = false,
            ["decoration.shadow.enabled"]   = false,
            ["decoration.active_opacity"]   = 1.0,
            ["decoration.inactive_opacity"] = 1.0,
            ["general.gaps_in"]             = 0,
            ["general.gaps_out"]            = 0,
        })
        hl.exec_cmd("notify-send -u low 'Game mode' 'ON: effects off'")
    else
        -- Reloading re-reads aesthetics.lua, restoring every original value
        hl.dispatch(hl.dsp.reload_config())
        hl.exec_cmd("notify-send -u low 'Game mode' 'OFF: neon restored'")
    end
end, { description = "Toggle game mode" })
