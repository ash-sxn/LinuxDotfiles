#!/bin/bash

# Arch Linux setup script
# This will install packages and set up your environment on a fresh Arch Linux installation

echo "Setting up Arch Linux environment..."

# Update the system
sudo pacman -Syu --noconfirm

# Install essential tools
sudo pacman -S --noconfirm base-devel git curl wget

# Install applications equivalent to your Ubuntu setup
sudo pacman -S --noconfirm firefox gnome-shell gnome-terminal gnome-control-center gnome-tweaks

# Check if yay is installed (AUR helper)
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install apps from AUR
echo "Installing applications from AUR..."
yay -S --noconfirm brave-bin visual-studio-code-bin kitty copyq ulauncher 

# Install GitHub CLI
yay -S --noconfirm github-cli

# Create symbolic links for dotfiles
echo "Setting up dotfiles..."
# Run from the dotfiles directory
if [ -d "$HOME/dotfiles_backup/.config" ]; then
    for dir in "$HOME/dotfiles_backup/.config"/*; do
        if [ -d "$dir" ]; then
            target="$HOME/.config/$(basename "$dir")"
            echo "Linking: $dir -> $target"
            mkdir -p "$(dirname "$target")"
            ln -sf "$dir" "$target"
        fi
    done
fi

# Link home dotfiles
if [ -d "$HOME/dotfiles_backup/home_dotfiles" ]; then
    for file in "$HOME/dotfiles_backup/home_dotfiles"/*; do
        if [ -f "$file" ]; then
            target="$HOME/.$(basename "$file")"
            echo "Linking: $file -> $target"
            ln -sf "$file" "$target"
        fi
    done
fi

# Install VS Code extensions
if [ -f "$HOME/dotfiles_backup/.config/vscode_extensions.txt" ]; then
    echo "Installing VS Code extensions..."
    while read extension; do
        code --install-extension "$extension" || true
    done < "$HOME/dotfiles_backup/.config/vscode_extensions.txt"
fi

# Import dconf settings
if [ -f "$HOME/dotfiles_backup/.config/dconf_settings.ini" ]; then
    echo "Importing dconf settings..."
    dconf load / < "$HOME/dotfiles_backup/.config/dconf_settings.ini"
fi

echo "Setup complete! Please restart your system for all changes to take effect."
