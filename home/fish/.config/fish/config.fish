source /usr/share/cachyos-fish-config/cachyos-config.fish

# Fix Claude Code display corruption in kitty
set -gx CLAUDE_CODE_FORCE_SYNC_OUTPUT 1

alias vim=nvim
alias disks="duf"

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SYSTEMD_EDITOR nvim

# Auto-start Hyprland if logged into TTY1
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec start-hyprland
    end
end

function windows
    sudo efibootmgr --bootnext 0000 && sudo reboot
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

function monitor
    switch $argv[1]
        case on
            hyprctl keyword monitor "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M32UC 22190B001233, 3840x2160@144, auto-right, 1.5, vrr, 2"
        case off
            hyprctl keyword monitor "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M32UC 22190B001233, disable"
        case '*'
            echo "Usage: monitor on|off"
    end
end

# Auto-attach tmux for interactive SSH sessions
if status is-interactive; and test -n "$SSH_TTY"; and not set -q TMUX; and not test -e "$HOME/.disable-auto-tmux"
    exec tmux new-session -A -s mobile
end
