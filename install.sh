#!/bin/bash
set -e
cd "$(dirname "$0")"

# stow only reads its global ignore list from ~/.stow-global-ignore,
# so install the repo's copy there rather than keeping it inert in stow/
echo "Installing stow ignore list..."
cp stow/.stow-global-ignore "$HOME/.stow-global-ignore"

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

echo "Done."
