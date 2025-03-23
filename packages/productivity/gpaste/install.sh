#!/bin/bash

# GPaste clipboard manager installation script

# Package information
PACKAGE_NAME="GPaste"
PACKAGE_DESCRIPTION="Clipboard manager for GNOME desktop environment"
PACKAGE_DOTFILES_DIR="$HOME/.config/gpaste"

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

# Check if GPaste is already installed
is_installed() {
    if command -v gpaste-client &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install GPaste on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    sudo apt update
    sudo apt install -y gpaste gnome-shell-extension-gpaste
    
    # Enable GNOME extension if GNOME is running
    if command -v gnome-shell &> /dev/null; then
        gnome-extensions enable gpaste@gnome-shell-extensions.gnome.org 2>/dev/null || true
        echo "GPaste GNOME extension enabled (if available)"
    fi
    
    # Start GPaste daemon
    gpaste-client daemon-reexec || true
}

# Install GPaste on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    sudo dnf install -y gpaste gnome-shell-extension-gpaste
    
    # Enable GNOME extension if GNOME is running
    if command -v gnome-shell &> /dev/null; then
        gnome-extensions enable gpaste@gnome-shell-extensions.gnome.org 2>/dev/null || true
        echo "GPaste GNOME extension enabled (if available)"
    fi
    
    # Start GPaste daemon
    gpaste-client daemon-reexec || true
}

# Install GPaste on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install from official repos
    sudo pacman -S --noconfirm gpaste
    
    # For GNOME integration
    sudo pacman -S --noconfirm gnome-shell-extension-gpaste || true
    
    # Enable GNOME extension if GNOME is running
    if command -v gnome-shell &> /dev/null; then
        gnome-extensions enable gpaste@gnome-shell-extensions.gnome.org 2>/dev/null || true
        echo "GPaste GNOME extension enabled (if available)"
    fi
    
    # Start GPaste daemon
    gpaste-client daemon-reexec || true
}

# Install GPaste on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    sudo zypper install -y gpaste
    
    # For GNOME integration
    sudo zypper install -y gnome-shell-extension-gpaste || true
    
    # Enable GNOME extension if GNOME is running
    if command -v gnome-shell &> /dev/null; then
        gnome-extensions enable gpaste@gnome-shell-extensions.gnome.org 2>/dev/null || true
        echo "GPaste GNOME extension enabled (if available)"
    fi
    
    # Start GPaste daemon
    gpaste-client daemon-reexec || true
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "GPaste is available on most Linux distributions."
    echo "Please install GPaste using your distribution's package manager."
    echo "For example:"
    echo "  - Debian/Ubuntu: sudo apt install gpaste"
    echo "  - Fedora: sudo dnf install gpaste"
    echo "  - Arch Linux: sudo pacman -S gpaste"
    
    return 1  # Return failure
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Set up default configuration
    if command -v gpaste-client &> /dev/null; then
        # Set GPaste to save history on exit
        gpaste-client settings --save-history true
        
        # Set maximum history size to 100 items
        gpaste-client settings --max-history-size 100
        
        # Set maximum display history size to 30 items
        gpaste-client settings --max-displayed-history-size 30
        
        # Set maximum text item size to 5000 characters
        gpaste-client settings --max-text-item-size 5000
        
        echo "GPaste default configuration has been set up."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        echo "$PACKAGE_NAME is already installed."
        read -p "Do you want to reinstall it? (y/N): " choice
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
    
    # Uninstall based on distribution family
    case $DISTRO_FAMILY in
        debian)
            sudo apt remove -y gpaste gnome-shell-extension-gpaste
            ;;
        redhat)
            sudo dnf remove -y gpaste gnome-shell-extension-gpaste
            ;;
        arch)
            sudo pacman -Rs --noconfirm gpaste gnome-shell-extension-gpaste
            ;;
        suse)
            sudo zypper remove -y gpaste gnome-shell-extension-gpaste
            ;;
        *)
            echo "Unsupported distribution for automatic uninstallation."
            echo "Please uninstall manually."
            ;;
    esac
    
    # Backup and remove config files
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        echo "Backing up configuration files..."
        backup_dir="$HOME/.config/backup/gpaste-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$PACKAGE_DOTFILES_DIR"/* "$backup_dir"/ 2>/dev/null || true
        
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