# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── home/          # User configs (~/)
│   ├── nvim/
│   ├── fish/
│   └── ...
├── root/          # System configs (/)
│   └── coolercontrol/
├── stow/
└── install.sh
```

## Installation

```bash
./install.sh
```

This will:
1. Stow all packages in `home/` to `$HOME`
2. Stow all packages in `root/` to `/` (requires sudo)

## Manual Usage

```bash
# Home packages
cd home && stow -t "$HOME" nvim

# Root packages
cd root && sudo stow -t / coolercontrol
```
