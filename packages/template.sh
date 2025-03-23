#!/bin/bash

# Template for package installation scripts
# This should be copied and modified for each package

# Package information
PACKAGE_NAME="Template Package"
PACKAGE_DESCRIPTION="Description of what this package does"
PACKAGE_DOTFILES_DIR="$HOME/.config/template" # Path to config files

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

# Check if the package is already installed
is_installed() {
    # This should be customized for each package
    if command -v template_package &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install package on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Add repositories if needed
    # sudo add-apt-repository ppa:some-ppa/ppa
    
    sudo apt update
    sudo apt install -y package-name
    
    # Post-installation steps
    # ...
}

# Install package on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Add repositories if needed
    # sudo dnf config-manager --add-repo https://example.com/repo
    
    sudo dnf install -y package-name
    
    # Post-installation steps
    # ...
}

# Install package on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Check if yay is installed for AUR packages
    if ! command -v yay &> /dev/null; then
        echo "Installing yay AUR helper..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    # Install from official repos
    sudo pacman -S --noconfirm package-name
    
    # Or install from AUR
    # yay -S --noconfirm aur-package-name
    
    # Post-installation steps
    # ...
}

# Install package on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Add repositories if needed
    # sudo zypper addrepo https://example.com/repo
    
    sudo zypper install -y package-name
    
    # Post-installation steps
    # ...
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    # Try to build from source, use universal installation script, etc.
    # ...
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Copy config files
    # cp -r "$(dirname "$0")/config/"* "$PACKAGE_DOTFILES_DIR/"
    
    # Set permissions
    # chmod +x "$PACKAGE_DOTFILES_DIR/script.sh"
    
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
            sudo apt remove -y package-name
            ;;
        redhat)
            sudo dnf remove -y package-name
            ;;
        arch)
            sudo pacman -Rs --noconfirm package-name
            ;;
        suse)
            sudo zypper remove -y package-name
            ;;
        *)
            echo "Unsupported distribution for automatic uninstallation."
            echo "Please uninstall manually."
            ;;
    esac
    
    # Backup and remove config files
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        echo "Backing up configuration files..."
        backup_dir="$HOME/.config/backup/template"
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