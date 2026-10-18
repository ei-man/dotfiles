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

- Runs v5 (`noctalia`, Arch `extra/noctalia`), started from `hyprland.conf`. Config is `home/noctalia/.config/noctalia/config.toml`; check it with `noctalia config validate`.
- `settings.json`, `colors.json`, `plugins.json` are the old v4 (Quickshell) config, kept for reference. v5 ignores them.
- Why v5: CachyOS's `noctalia-shell` 5.2.1 package ships v5 source under the v4 name and doesn't run. v4 also depends on the orphaned `noctalia-qs`, which keeps falling behind Qt.
- Plugins (`[plugins].enabled`) are fetched into `~/.local/state/noctalia/` on startup. A config hot-reload doesn't fetch newly enabled ones, so restart `noctalia`.
- `swaync` was removed (2026-10-18): D-Bus started it whenever no bar was running, and it then held the notification name so v5 had no notifications.
- v4 look: the v4 workspace pills with app icons are v5's `taskbar` with `group_by_workspace`. The v4 bar was 47 px (density "spacious"). Noctalia runs with `LC_TIME=en_DK.UTF-8` so the clock shows English day/month names like v4 did, while the system LC_TIME stays Danish.
