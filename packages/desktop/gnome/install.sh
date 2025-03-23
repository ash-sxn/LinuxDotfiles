#!/bin/bash

# GNOME Desktop Environment installation script

# Package information
PACKAGE_NAME="GNOME Desktop Environment"
PACKAGE_DESCRIPTION="A desktop environment that aims to be simple and easy to use"
PACKAGE_DOTFILES_DIR="$HOME/.config/gnome"

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        
        # Handle distribution families
        case $DISTRO in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                DISTRO_FAMILY="debian"
                ;;
            fedora|rhel|centos|rocky|alma)
                DISTRO_FAMILY="redhat"
                ;;
            arch|manjaro|endeavouros|artix|garuda)
                DISTRO_FAMILY="arch"
                ;;
            opensuse*)
                DISTRO_FAMILY="suse"
                ;;
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
    else
        DISTRO="unknown"
        DISTRO_FAMILY="unknown"
    fi
    
    echo "Detected distribution: $DISTRO (Family: $DISTRO_FAMILY)"
}

# Check if GNOME is already installed
is_installed() {
    if command -v gnome-shell &> /dev/null; then
        return 0  # true, GNOME is installed
    else
        return 1  # false, GNOME is not installed
    fi
}

# Install GNOME on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    sudo apt update
    sudo apt install -y gnome-shell gnome-control-center gnome-tweaks gnome-shell-extensions
    
    # Install additional GNOME applications
    sudo apt install -y nautilus gedit gnome-terminal gnome-calculator gnome-system-monitor
    
    # Set gdm3 as default display manager if available
    if command -v gdm3 &> /dev/null; then
        sudo systemctl enable gdm3
    fi
}

# Install GNOME on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Install GNOME workstation
    sudo dnf groupinstall -y "GNOME Desktop Environment"
    
    # Install additional tools
    sudo dnf install -y gnome-tweaks gnome-extensions-app
    
    # Set GDM as default display manager
    sudo systemctl enable gdm
}

# Install GNOME on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install GNOME group
    sudo pacman -S --noconfirm gnome
    
    # Install additional tools
    sudo pacman -S --noconfirm gnome-tweaks gnome-shell-extensions
    
    # Enable GDM
    sudo systemctl enable gdm
}

# Install GNOME on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Install GNOME pattern
    sudo zypper install -y -t pattern gnome
    
    # Install additional tools
    sudo zypper install -y gnome-tweaks
    
    # Enable GDM
    sudo systemctl enable gdm
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "GNOME installation might not be automated for your distribution."
    echo "Please refer to your distribution's documentation for installing GNOME."
}

# Setup GNOME configuration files and settings
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Apply GNOME settings if installed
    if command -v gsettings &> /dev/null; then
        # Set preferred settings
        gsettings set org.gnome.desktop.interface enable-animations true
        gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        
        # Terminal settings
        gsettings set org.gnome.Terminal.Legacy.Settings theme-variant "dark"
        
        # Copy any additional configuration files
        cp -r "$(dirname "$0")/config/"* "$PACKAGE_DOTFILES_DIR/" 2>/dev/null || true
    else
        echo "gsettings command not found. Cannot apply GNOME settings."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        echo "$PACKAGE_NAME is already installed."
        read -p "Do you want to reinstall/update it? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            echo "Skipping installation."
            return
        fi
    fi
    
    # Install based on distribution family
    case $DISTRO_FAMILY in
        debian)
            install_debian
            ;;
        redhat)
            install_redhat
            ;;
        arch)
            install_arch
            ;;
        suse)
            install_suse
            ;;
        *)
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        setup_config
    else
        echo "Failed to install $PACKAGE_NAME."
        exit 1
    fi
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    if ! is_installed; then
        echo "$PACKAGE_NAME is not installed."
        return
    fi
    
    echo "WARNING: Uninstalling GNOME might affect your current desktop environment."
    read -p "Are you sure you want to proceed? (y/N): " choice
    if [[ ! $choice =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        return
    fi
    
    # Uninstall based on distribution family
    case $DISTRO_FAMILY in
        debian)
            sudo apt remove --autoremove -y gnome-shell gnome-control-center gnome-tweaks gnome-shell-extensions
            ;;
        redhat)
            sudo dnf groupremove -y "GNOME Desktop Environment"
            ;;
        arch)
            sudo pacman -Rs --noconfirm gnome
            ;;
        suse)
            sudo zypper remove -y -t pattern gnome
            ;;
        *)
            echo "Unsupported distribution for automatic uninstallation."
            echo "Please uninstall manually."
            ;;
    esac
    
    # Backup and remove config files
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        echo "Backing up configuration files..."
        backup_dir="$HOME/.config/backup/gnome"
        mkdir -p "$backup_dir"
        cp -r "$PACKAGE_DOTFILES_DIR" "$backup_dir"
        
        read -p "Do you want to remove configuration files? (y/N): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            rm -rf "$PACKAGE_DOTFILES_DIR"
            echo "Configuration files removed."
        fi
    fi
    
    echo "$PACKAGE_NAME has been uninstalled."
}

# Parse command line arguments
if [ "$1" == "uninstall" ]; then
    detect_distro
    uninstall_package
else
    detect_distro
    install_package
fi 