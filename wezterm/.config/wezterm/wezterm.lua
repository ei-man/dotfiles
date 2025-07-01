-- Pull in WezTerm API
local wezterm = require "wezterm"

-- Initialize actual config
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Appearance
config.font = wezterm.font "JetBrainsMono Nerd Font"
config.font_size = 13.0
config.color_scheme = "Material Darker (base16)"
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = false
config.window_close_confirmation = "NeverPrompt"

-- Keybindings
config.keys = {
    -- Default QuickSelect keybind (CTRL-SHIFT-Space) gets captured by something
    -- else on my system
    {
        key = "A",
        mods = "CTRL",
        action = wezterm.action.QuickSelect,
    },
    -- Quickly open config file with common macOS keybind
    {
        key = "P",
        mods = "CTRL",
        action = wezterm.action.SpawnCommandInNewWindow({
            cwd = os.getenv "WEZTERM_CONFIG_DIR",
            args = { os.getenv "SHELL", "-c", "goland $WEZTERM_CONFIG_FILE" },
        }),
    },
    {
        key = "O",
        mods = "CTRL",
        action = wezterm.action { QuickSelectArgs = {
            patterns = {
                "https?://\\S+"
            },
            action = wezterm.action_callback(function(window, pane)
                local url = window:get_selection_text_for_pane(pane)
                wezterm.open_with(url)
            end)
        } }
    },
    {
        key = "G",
        mods = "CTRL",
        action = wezterm.action { QuickSelectArgs = {
            patterns = {
                "\\S+:\\d+:\\d+"
            },
            action = wezterm.action_callback(function(window, pane)
                local url = window:get_selection_text_for_pane(pane)
                local sep = ":"
                local results = {}
                for str in string.gmatch(url, "([^" .. sep .. "]+)") do
                    table.insert(results, str)
                end

                if #results ~= 3 then
                    return
                end

                local path = results[1]
                local line = results[2]
                local column = results[3]
                if not string.find(path, "go-code") then
                    path = "/Users/eimantas.sipalis/go-code/" .. path
                end

                wezterm.log_info("opening with goland", path, line, column)

                local _, _, _ = wezterm.run_child_process { 'goland', path, '--line ' .. line, '--column ' .. column }
            end)
        } }
    },
}

-- Return config to WezTerm
return config
