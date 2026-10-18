#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Stowing home packages..."
cd home
for pkg in */; do
    stow --restow -t "$HOME" "${pkg%/}"
done
cd ..

echo "Stowing root packages (requires sudo)..."
cd root
for pkg in */; do
    sudo stow --restow -t / "${pkg%/}"
done
cd ..

# Enable (and start) every stowed unit that has an [Install] section and isn't enabled yet,
# so a new service or timer works right after stowing. Template units (foo@.service) are skipped.
enable_units() {
    local dir=$1; shift
    "$@" daemon-reload
    for unit in $dir/*.service $dir/*.timer $dir/*.socket $dir/*.path; do
        [ -f "$unit" ] && grep -q '^\[Install\]' "$unit" || continue
        local name=${unit##*/}
        [[ $name == *@.* ]] && continue
        "$@" is-enabled -q "$name" || { echo "Enabling $name"; "$@" enable --now "$name"; }
    done
}
echo "Enabling units..."
enable_units 'home/*/.config/systemd/user' systemctl --user
enable_units 'root/*/etc/systemd/system' sudo systemctl

echo "Done."
