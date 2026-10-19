-- https://wiki.hypr.land/Configuring/
-- API reference for every hl.* call: /usr/share/hypr/stubs/hl.meta.lua
-- Check after editing: Hyprland --verify-config -c ~/.config/hypr/hyprland.lua


------------------
---- MONITORS ----
------------------

local mainMonitor = "desc:ASUSTek COMPUTER INC PG32UCDM T7LMQS135504"

hl.monitor({
    output   = mainMonitor,
    mode     = "3840x2160@240",
    position = "auto-left",
    scale    = 1.5,
    bitdepth = 10,
    vrr      = 2,
})
-- Toggled from fish (`monitor on|off`); keep that copy in sync.
hl.monitor({
    output   = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M32UC 22190B001233",
    mode     = "3840x2160@144",
    position = "auto-right",
    scale    = 1.5,
    vrr      = 2,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "walker"
-- Autostarts that want the network wait for it here. nm-online has no "forever"
-- option, so this is its maximum (24 days); the 30s default silently dropped
-- Chrome and both browser-router tabs on 2026-09-20, when the machine came back
-- an hour before the internet did.
local waitnet     = "nm-online --quiet --timeout 2073600"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("elephant") -- walker backend; must run before walker/clipboard history works
    hl.exec_cmd("walker --gapplication-service") -- keep walker resident so super+space opens instantly
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprlock")
    -- Noctalia v5. LC_TIME gives the clock English day/month names like v4 had;
    -- the system LC_TIME is Danish.
    hl.exec_cmd("env LC_TIME=en_DK.UTF-8 noctalia")
    -- The workspace rules send each autostarted window to its home workspace
    -- without the placement outliving startup: launch any of these by hand
    -- later and it opens on the current workspace like anything else.
    hl.exec_cmd(terminal, { workspace = "3 silent" })
    -- Starts the Claude Remote Control host and brings back every session that is not
    -- archived in the app. Waits for the network; the claude-remote-restore systemd timer
    -- runs the same thing every 2 minutes and catches up on anything this run misses.
    hl.exec_cmd(waitnet .. " && ~/.local/bin/claude-remote-restore", { workspace = "3 silent" })
    -- --restore-last-session reopens every tab from the previous session;
    -- --hide-crash-restore-bubble suppresses the "Restore pages?" prompt that
    -- otherwise appears because Hyprland kills Chrome rather than closing it.
    hl.exec_cmd(waitnet .. " && google-chrome-stable --restore-last-session --hide-crash-restore-bubble", { workspace = "1 silent" })
    hl.exec_cmd("vesktop", { workspace = "4 silent" })
    -- easyeffects: not started; its sink grabbed every stream, blocking per-app output routing
    hl.exec_cmd("kdeconnectd")
    -- steam: crashes when started from here, so "Launch at startup" is enabled in Steam instead
    -- Routed through browser-router so these match how links get handed to Firefox;
    -- --no-focus keeps them from stealing the workspace while everything else starts.
    -- These need --workspace rather than a workspace rule: browser-router starts
    -- Firefox with setsid, which detaches it and breaks the parent-pid chain the
    -- rule relies on.
    hl.exec_cmd(waitnet .. " && ~/.local/bin/browser-router --no-focus --workspace 2 'https://www.youtube.com'")
    hl.exec_cmd(waitnet .. " && ~/.local/bin/browser-router --no-focus --workspace 5 'https://music.youtube.com'")
    hl.exec_cmd("gpu-screen-recorder -w DP-3 -f 60 -a default_output -a default_input -c mp4 -k h264 -r 300 -o ~/Videos/Replays")
    -- clipboard history is handled by elephant (walker backend); cliphist is no longer used
end)


--------------------------------------------
---- AUTO-ASSIGN PROGRAMS TO WORKSPACES ----
--------------------------------------------
-- There are deliberately no class -> workspace rules here: the autostart block
-- above tags its own windows, so a program started by hand opens on whatever
-- workspace is in front of you. Steam is the exception, since it is launched by
-- Steam's own "Launch at startup" and nothing Hyprland spawns is its parent.
hl.window_rule({
    name      = "steam-tiled",
    match     = { class = "steam" },
    workspace = "7 silent",
    tile      = true,
})

hl.window_rule({
    name         = "steam-untitled-float",
    match        = { class = "steam", title = "^$" },
    stay_focused = true,
    float        = true,
})

for ws = 1, 7 do
    hl.workspace_rule({ workspace = tostring(ws), monitor = mainMonitor })
end


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_MENU_PREFIX", "arch-")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        -- Shrinks the tiling area to what a 27" panel would give, so the wallpaper
        -- stays visible around the edges. Both monitors are 32" 16:9 at scale 1.5,
        -- i.e. 2560x1440 logical; 27/32 of that is 2160x1215, leaving 113px top and
        -- bottom and 200px either side.
        gaps_out = { top = 113, right = 200, bottom = 113, left = 200 },

        border_size = 2,

        col = {
            active_border   = "rgba(808080aa)",
            inactive_border = "rgba(606060aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
        render_unfocused_fps    = 15,
    },

    cursor = {
        no_warps         = true,
        inactive_timeout = 5,
    },

    quirks = {
        -- 2 = only enable HDR preference for gamescope, 1 = always, 0 = off (default)
        prefer_hdr = 2,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout      = "us",
        sensitivity    = -0.333, -- -1.0 to 1.0, 0 means no modification.
        accel_profile  = "flat", -- Disables the Linux acceleration curve.
        force_no_accel = true,   -- Redundant safety to force raw input.
        follow_mouse   = 0,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------
-- `description` is what the Noctalia keybind cheatsheet shows.

local mainMod = "SUPER"

hl.bind("ALT + F10", hl.dsp.exec_cmd("killall -SIGUSR1 gpu-screen-recorder"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("wl-paste --no-newline | ydotool type --file=-"))

-- 1. General
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd([[sh -c 'before=$(wl-paste -n 2>/dev/null | sha256sum); bak=$(mktemp); btype=$(wl-paste -n --list-types 2>/dev/null | head -1); wl-paste -n > "$bak" 2>/dev/null; walker -m clipboard; sleep 0.1; after=$(wl-paste -n 2>/dev/null | sha256sum); if [ "$before" != "$after" ]; then wtype -M ctrl v -m ctrl; sleep 0.3; if [ -s "$bak" ]; then wl-copy --type "${btype:-text/plain}" < "$bak"; else wl-copy --clear; fi; fi; rm -f "$bak"']]),
    { description = "Clipboard history (paste, keep current clipboard)" })
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu), { description = "Open app launcher" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"), { description = "Screenshot region" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd([[loginctl lock-session & sleep 1 && hyprctl dispatch 'hl.dsp.dpms({ action = "off" })']]),
    { description = "Lock & screen off" })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle group (tabbed/stacked)" })
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ into_group = "l" }), { description = "Move window into group left" })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ into_group = "r" }), { description = "Move window into group right" })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ into_group = "u" }), { description = "Move window into group up" })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ into_group = "d" }), { description = "Move window into group down" })
hl.bind(mainMod .. " + TAB", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev(), { description = "Prev window in group" })

for _, d in ipairs({ { "left", "H" }, { "right", "L" }, { "up", "K" }, { "down", "J" } }) do
    hl.bind(mainMod .. " + " .. d[1], hl.dsp.focus({ direction = d[1] }))
    hl.bind(mainMod .. " + " .. d[2], hl.dsp.focus({ direction = d[1] }))
end

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "+1" }), { description = "Move workspace to next monitor" })

-- 2. Special Workspace
hl.bind(mainMod .. " + CTRL + S", hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
hl.bind(mainMod .. " + CTRL + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move to scratchpad" })

-- 3. Mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll workspace next" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll workspace prev" })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { description = "Move window (drag)" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "Resize window (drag)" })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

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

hl.layer_rule({
    name         = "noctalia",
    match        = { namespace = "noctalia-background-.*$" },
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})

-- Games: keep them fullscreen and rendering on workspace 8 even when unfocused.
for name, class in pairs({ ["dota2-keep-fullscreen"] = "dota2", ["cs2-keep-fullscreen"] = "gamescope" }) do
    hl.window_rule({
        name             = name,
        match            = { class = class },
        workspace        = "8 silent",
        fullscreen       = true,
        render_unfocused = true,
        suppress_event   = "fullscreen",
    })
end


-----------------------------------
---- FREE-FLOAT WORKSPACE (O) ----
-----------------------------------
-- SUPER+O switches the current workspace between tiling and free-floating: it
-- floats (or tiles) the windows already there and turns on (or off) a rule
-- that floats new windows opened on it. The rule itself holds the state, so a
-- config reload resets every workspace to tiling.
local floatWorkspaceRules = {}
for ws = 1, 10 do
    floatWorkspaceRules[ws] = hl.window_rule({
        name    = "float-ws-" .. ws,
        match   = { workspace = ws },
        float   = true,
        enabled = false,
    })
end

hl.bind(mainMod .. " + O", function()
    local ws = hl.get_active_workspace()
    local rule = ws and floatWorkspaceRules[ws.id]
    if not rule then return end

    local floating = not rule:is_enabled()
    rule:set_enabled(floating)
    for _, window in ipairs(hl.get_workspace_windows(ws.id)) do
        hl.dispatch(hl.dsp.window.float({ action = floating and "enable" or "disable", window = window }))
    end
end, { description = "Toggle workspace free-float" })
