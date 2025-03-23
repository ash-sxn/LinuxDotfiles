#!/bin/bash

# GPaste configuration setup script

# Package information
PACKAGE_NAME="GPaste"
PACKAGE_DOTFILES_DIR="$HOME/.config/gpaste"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

# Check if GPaste is installed
if ! command -v gpaste-client &> /dev/null; then
    echo "Error: GPaste is not installed. Please install it first."
    exit 1
fi

echo "Setting up configuration for $PACKAGE_NAME..."

# Create config directory if it doesn't exist
mkdir -p "$PACKAGE_DOTFILES_DIR"

# Set up default configuration using GPaste client
echo "Configuring GPaste settings..."

# Save history on exit
gpaste-client settings --save-history true

# Set maximum history size to 100 items
gpaste-client settings --max-history-size 100

# Set maximum display history size to 30 items
gpaste-client settings --max-displayed-history-size 30

# Set maximum text item size to 5000 characters
gpaste-client settings --max-text-item-size 5000

# Set the keyboard shortcut for showing history
gsettings set org.gnome.GPaste show-history '<Ctrl><Alt>h' 2>/dev/null || true

# Enable GNOME shell extension if available
if command -v gnome-shell &> /dev/null; then
    gnome-extensions enable gpaste@gnome-shell-extensions.gnome.org 2>/dev/null || true
    echo "GPaste GNOME extension enabled (if available)"
fi

# Start/restart GPaste daemon
echo "Starting GPaste daemon..."
gpaste-client daemon-reexec || gpaste-client start

echo "GPaste configuration completed successfully!" 