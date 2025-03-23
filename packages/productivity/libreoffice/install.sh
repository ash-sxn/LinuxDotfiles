#!/bin/bash

# LibreOffice installation script

# Package information
PACKAGE_NAME="LibreOffice"
PACKAGE_DESCRIPTION="Free and open-source office suite"

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
    if command -v libreoffice &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install package on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    sudo apt update
    sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-gnome
}

# Install package on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    sudo dnf install -y libreoffice
}

# Install package on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install from official repos
    sudo pacman -S --noconfirm libreoffice-fresh libreoffice-fresh-{en-us,nl,fr,de,es,it,pt,ru,zh-cn,ja,ko} hunspell hunspell-en_us
}

# Install package on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    sudo zypper install -y libreoffice
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "Please visit https://www.libreoffice.org/download/download/ for instructions on downloading and installing LibreOffice for your distribution."
    exit 1
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
            sudo apt remove --autoremove -y libreoffice libreoffice-gtk3 libreoffice-gnome
            ;;
        redhat)
            sudo dnf remove -y libreoffice
            ;;
        arch)
            sudo pacman -Rs --noconfirm libreoffice-fresh
            ;;
        suse)
            sudo zypper remove -y libreoffice
            ;;
        *)
            echo "Unsupported distribution for automatic uninstallation."
            echo "Please uninstall manually."
            ;;
    esac
    
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