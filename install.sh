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

echo "Done."
