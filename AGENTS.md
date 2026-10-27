# AGENTS.md

Personal dotfiles repo, managed with GNU Stow. `home/<pkg>/` stows into `~`, `root/<pkg>/` into `/`.

New configs, user scripts and systemd user units go in a package here and get stowed — never write them straight into `~/.config` or `~/.local`.

`./install.sh` applies everything: restows all packages, then enables and starts any unit with an `[Install]` section that isn't enabled yet. To keep a unit off, leave out its `[Install]` section.

**This repo is public on GitHub.** Before every commit, check the diff for tokens, API keys, IPs/hostnames and personal data; secrets stay in untracked env files.

## Commits

- Commit everything in one commit unless told otherwise.
- Keep messages to ~10-20 words. Summarize, don't enumerate every file.
- No need to be pedantic here — it's dotfiles, not production code.

## Noctalia (bar/shell)

- Runs v5 (`noctalia`, Arch `extra/noctalia`), started from `hyprland.lua`. Config is `home/noctalia/.config/noctalia/config.toml`; check it with `noctalia config validate`.
- `settings.json`, `colors.json`, `plugins.json` are the old v4 (Quickshell) config, kept for reference. v5 ignores them.
- Why v5: CachyOS's `noctalia-shell` 5.2.1 package ships v5 source under the v4 name and doesn't run. v4 also depends on the orphaned `noctalia-qs`, which keeps falling behind Qt.
- Plugins (`[plugins].enabled`) are fetched into `~/.local/state/noctalia/` on startup. A config hot-reload doesn't fetch newly enabled ones, so restart `noctalia`.
- `swaync` was removed (2026-10-18): D-Bus started it whenever no bar was running, and it then held the notification name so v5 had no notifications.
- v4 look: the v4 workspace pills with app icons are v5's `taskbar` with `group_by_workspace`. The v4 bar was 47 px (density "spacious"). Noctalia runs with `LC_TIME=en_DK.UTF-8` so the clock shows English day/month names like v4 did, while the system LC_TIME stays Danish.
- v5's own lock screen is off (`[lockscreen] enabled = false`); hyprlock is the only locker. With both on, both answer logind's lock signal, Hyprland refuses the loser, and v5 exits on that refusal: the bar vanished after the 1 h idle lock on 2026-10-19.

## Hyprland

- Config is `home/hypr/.config/hypr/hyprland.lua`. Hyprland 0.56 deprecated `hyprland.conf` and 0.57 drops it. The API reference is `/usr/share/hypr/stubs/hl.meta.lua`.
- Check edits with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`. It catches bad types and values but not unknown field names, and a toggle `action` it doesn't know (only `enable`/`on`, `disable`/`off`, `toggle`) silently toggles.
- Scripts: `hyprctl keyword` is gone, use `hyprctl eval '<lua>'`. `hyprctl dispatch` takes Lua (`hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'`). Used in hypridle.conf, browser-router and fish's `monitor`.
- Hyprland picks Lua vs `.conf` once at startup. Deleting `hyprland.conf` under a running `.conf` session makes it write a stub and reload into default binds.
- Autostart placement (`hl.exec_cmd(cmd, { workspace = "N silent" })`) is used up by the program's first window and expires after 1 minute (Hyprland source: `WindowRuleApplicator.cpp`, `Rule.cpp`). Vesktop's splash window used to take it, so the splash is off in Vesktop's settings (`enableSplashScreen`, local `~/.config/vesktop/settings.json`, not stowed because Vesktop rewrites it).
- SUPER+W stacks every tiled window on the workspace into one tab group (SUPER+TAB or SUPER+J/K cycle it); pressed again it splits them back. J/K/up/down cycle a stack because `binds:movefocus_cycles_groupfirst` only covers left/right.
- SUPER+M cycles the workspace layout dwindle → monocle → scrolling via per-workspace `hl.workspace_rule` handles toggled with `set_enabled` (Hyprland re-lays out open windows on the spot; a reload resets to dwindle). In monocle, SUPER+J/K send `cyclenext`/`cycleprev`.
- hyprlang2lua (third-party converter) got ~92% right but left 3 config errors and mapped `setfloating` to a value that toggles, so the Lua was written by hand.

## Chrome

- The profile lives in `~/.config/google-chrome-main`; `~/.config/google-chrome` is a symlink to it. `home/chrome-cdp/.config/chrome-flags.conf` (read by `/usr/bin/google-chrome-stable`) adds `--user-data-dir=…-main --remote-debugging-port=9222`, so tools (Claude's `chrome-live` MCP) connect to 127.0.0.1:9222 with no Allow dialog.
- Why: Chrome 136+ ignores `--remote-debugging-port` on the default data dir, which left only the `chrome://inspect` consent route (an Allow click per connection). Tested 2026-10-27: passing the default path explicitly is ignored, and so is a symlink *to* the default dir (Chrome resolves it). Moving the real dir and launching from the new path works.
- The symlink means a launch that skips the wrapper (`/opt/google/chrome/chrome`) still opens the same profile, just without the port.
- This replaced `chrome-cdp-proxy` (Aug–Oct 2026), a daemon that held one approved connection and re-served it on :9223. Its reconnect loop raised a fresh Allow dialog about once a minute whenever nobody clicked.
- Trade-off: any local process running as the user can drive the logged-in browser. Little is lost on this host: no keyring daemon runs, so Chrome's cookie store is already readable by any such process.
