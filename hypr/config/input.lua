--------------------------------------------------------------------------------
--                                   INPUT                                    --
--------------------------------------------------------------------------------
-- Keyboard, mouse and touchpad behavior.
--
-- See: https://wiki.hypr.land/configuring/core/devices/
--------------------------------------------------------------------------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0, 0 means no modification

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Three-finger horizontal swipe switches workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device example (run `hyprctl devices` for names)
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
