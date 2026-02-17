#!/bin/bash
# Dotfiles installer - symlinks config files to home directory

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "Dotfiles linked successfully!"
