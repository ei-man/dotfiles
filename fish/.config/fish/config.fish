source /usr/share/cachyos-fish-config/cachyos-config.fish

alias vim=nvim

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SYSTEMD_EDITOR nvim

# Auto-start Hyprland if logged into TTY1
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec start-hyprland
    end
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
