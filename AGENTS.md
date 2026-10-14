# AGENTS.md

Personal dotfiles repo, managed with GNU Stow. `home/<pkg>/` stows into `~`, `root/<pkg>/` into `/`.

New configs, user scripts and systemd user units go in a package here and get stowed — never write them straight into `~/.config` or `~/.local`.

**This repo is public on GitHub.** Before every commit, check the diff for tokens, API keys, IPs/hostnames and personal data; secrets stay in untracked env files.

## Commits

- Commit everything in one commit unless told otherwise.
- Keep messages to ~10-20 words. Summarize, don't enumerate every file.
- No need to be pedantic here — it's dotfiles, not production code.
