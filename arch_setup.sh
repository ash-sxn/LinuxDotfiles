#!/bin/bash

# arch_setup.sh
# Script for setting up a new Arch Linux system with GNOME
# This is meant to replace the Ubuntu-specific setup script

# Exit on error
set -e

echo "Starting Arch Linux system setup..."

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install packages with pacman
install_pacman_packages() {
    echo "Installing packages with pacman..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm base-devel git curl wget gnome gnome-tweaks gnome-shell-extensions \
                                firefox kitty neovim tmux zsh htop
}

# Function to install AUR helper (yay)
install_yay() {
    if ! command_exists yay; then
        echo "Installing yay (AUR helper)..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
    else
        echo "yay is already installed."
    fi
}

# Function to install AUR packages
install_aur_packages() {
    echo "Installing packages from AUR..."
    yay -S --noconfirm brave-bin visual-studio-code-bin copyq ulauncher github-cli
}

# Function to set up GNOME
setup_gnome() {
    echo "Setting up GNOME..."
    
    # Enable GDM
    sudo systemctl enable gdm.service
    
    # Set GNOME as default desktop environment
    if [ -f /usr/bin/gnome-session ]; then
        sudo ln -sf /usr/bin/gnome-session /usr/bin/default-session
    fi
    
    # Install GNOME extensions if extensions tool exists
    if command_exists gnome-extensions-app; then
        echo "Consider installing extensions through the GNOME Extensions app"
    fi
    
    # Apply GNOME settings if we have a backup
    if [ -f "$HOME/.config/dconf/user" ]; then
        echo "Restoring GNOME settings from backup..."
        dconf load / < "$HOME/.config/dconf/user"
    fi
}

# Function to configure system settings
configure_system() {
    echo "Configuring system settings..."
    
    # Enable NetworkManager
    sudo systemctl enable NetworkManager.service
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth.service
    
    # Configure time synchronization
    sudo systemctl enable systemd-timesyncd.service
    
    # Set up firewall
    if command_exists ufw; then
        sudo ufw enable
    fi
    
    # Enable SSD trimming if applicable
    sudo systemctl enable fstrim.timer
}

# Function to restore configuration files
restore_config() {
    echo "Restoring configuration files..."
    
    # Check if we have any backed up config files
    if [ -d "$HOME/.config-backup" ]; then
        # Restore .config directory files
        cp -r "$HOME/.config-backup/"* "$HOME/.config/"
    fi
    
    # Link dotfiles if they exist
    for dotfile in .bashrc .zshrc .vimrc .tmux.conf .gitconfig; do
        if [ -f "$HOME/.dotfiles/$dotfile" ]; then
            ln -sf "$HOME/.dotfiles/$dotfile" "$HOME/$dotfile"
        fi
    done
}

# Function to install and configure ZSH
setup_zsh() {
    echo "Setting up ZSH..."
    
    # Install Oh My ZSH if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Set ZSH as default shell
    chsh -s $(which zsh)
}

# Main execution
echo "==== Arch Linux Setup Script ===="
echo "This script will set up your new Arch Linux system with GNOME desktop environment."
echo "It will install essential packages and restore your configuration files."
echo

# Confirm before proceeding
read -p "Continue with setup? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

# Run installation steps
install_pacman_packages
install_yay
install_aur_packages
setup_gnome
configure_system
restore_config
setup_zsh

echo
echo "==== Setup Complete ===="
echo "Please reboot your system to apply all changes."
echo "After reboot, consider:"
echo "1. Checking your display settings"
echo "2. Setting up any remaining application configurations"
echo "3. Importing browser bookmarks and settings"
echo
echo "Enjoy your new Arch Linux system!" 