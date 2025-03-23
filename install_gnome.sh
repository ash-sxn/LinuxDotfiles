#!/bin/bash

# Script to install the latest GNOME Desktop Environment

# Package information
PACKAGE_NAME="GNOME Desktop Environment"
PACKAGE_DESCRIPTION="Modern desktop environment with a focus on simplicity and user experience"

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_ID=$VERSION_ID
        
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
        VERSION_ID="unknown"
    fi
    
    echo "Detected distribution: $DISTRO (Family: $DISTRO_FAMILY, Version: $VERSION_ID)"
}

# Check if GNOME is already installed
is_installed() {
    if [ -d "/usr/share/gnome" ] || [ -d "/usr/share/gnome-shell" ] || command -v gnome-shell &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install GNOME on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Update package index
    sudo apt update
    
    if [ "$DISTRO" = "ubuntu" ]; then
        # For Ubuntu, add the GNOME Team PPA to get the latest version
        echo "Adding GNOME Team PPA for latest GNOME version..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:gnome-team/gnome-nightly
        sudo apt update
        
        # Install the latest GNOME Desktop Environment
        sudo apt install -y ubuntu-gnome-desktop gnome-shell gnome-shell-extensions gnome-tweaks
    else
        # For other Debian-based distributions
        sudo apt install -y gnome gnome-shell gnome-shell-extensions gnome-tweaks
    fi
    
    # Install additional GNOME components and tools
    sudo apt install -y gnome-backgrounds gnome-session gnome-terminal gnome-control-center gnome-software
    
    # Install theming tools and dependencies
    sudo apt install -y sassc libglib2.0-dev git meson
    
    return $?
}

# Install GNOME on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    if [ "$DISTRO" = "fedora" ]; then
        # Fedora usually has the latest GNOME version
        sudo dnf install -y @gnome gnome-shell gnome-shell-extensions gnome-tweaks
    else
        # For RHEL, CentOS, Rocky, etc.
        sudo yum install -y epel-release
        sudo yum groupinstall -y "Server with GUI" "GNOME Desktop"
        sudo yum install -y gnome-shell gnome-shell-extensions gnome-tweaks
    fi
    
    # Install theming tools and dependencies
    sudo dnf install -y sassc glib2-devel git meson || sudo yum install -y sassc glib2-devel git meson
    
    return $?
}

# Install GNOME on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install GNOME Desktop Environment
    sudo pacman -S --noconfirm gnome gnome-extra gnome-shell-extensions gnome-tweaks
    
    # Install theming tools and dependencies
    sudo pacman -S --noconfirm sassc glib2 git meson base-devel
    
    # Enable GDM service to start on boot
    sudo systemctl enable gdm.service
    
    return $?
}

# Install GNOME on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Install GNOME Desktop Environment
    sudo zypper install -y -t pattern gnome gnome_basis gnome_admin gnome_games gnome_imaging gnome_utilities
    sudo zypper install -y gnome-shell-extensions gnome-tweaks
    
    # Install theming tools and dependencies
    sudo zypper install -y sassc glib2-devel git meson
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    # Try to use the system's package manager
    if command -v apt &> /dev/null; then
        install_debian
    elif command -v dnf &> /dev/null; then
        install_redhat
    elif command -v yum &> /dev/null; then
        install_redhat
    elif command -v pacman &> /dev/null; then
        install_arch
    elif command -v zypper &> /dev/null; then
        install_suse
    else
        echo "Could not determine a suitable package manager."
        echo "Please install GNOME manually following your distribution's documentation."
        return 1
    fi
    
    return $?
}

# Install extension manager and necessary tools for customization
install_extension_tools() {
    echo "Installing Extension Manager and customization tools..."
    
    case $DISTRO_FAMILY in
        debian)
            sudo apt install -y chrome-gnome-shell gnome-shell-extension-manager
            ;;
        redhat)
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf install -y chrome-gnome-shell gnome-shell-extension-manager
            else
                sudo yum install -y chrome-gnome-shell || true
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm gnome-browser-connector gnome-shell-extension-manager
            ;;
        suse)
            sudo zypper install -y chrome-gnome-shell || true
            ;;
        *)
            echo "Extension manager might not be available for your distribution."
            echo "You can install extensions from https://extensions.gnome.org/ manually."
            ;;
    esac
    
    # Install Flatpak and Flathub repository for additional apps
    if ! command -v flatpak &> /dev/null; then
        echo "Installing Flatpak..."
        case $DISTRO_FAMILY in
            debian)
                sudo apt install -y flatpak
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf install -y flatpak
                else
                    sudo yum install -y flatpak
                fi
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            arch)
                sudo pacman -S --noconfirm flatpak
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            suse)
                sudo zypper install -y flatpak
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
        esac
    fi
    
    echo "Installing theme-related Flatpak applications..."
    sudo flatpak install -y flathub com.mattjakeman.ExtensionManager || true
    sudo flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark || true
    
    return 0
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        GNOME_VERSION=$(gnome-shell --version 2>/dev/null || echo "GNOME is installed (version cannot be determined)")
        echo "$PACKAGE_NAME is already installed: $GNOME_VERSION"
        read -p "Do you want to update/reinstall it? (y/N): " choice
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
        GNOME_VERSION=$(gnome-shell --version 2>/dev/null || echo "Version cannot be determined")
        echo "Version: $GNOME_VERSION"
        
        # Install customization tools
        read -p "Do you want to install additional tools for GNOME customization? (Y/n): " tools_choice
        if [[ ! $tools_choice =~ ^[Nn]$ ]]; then
            install_extension_tools
        fi
        
        echo "You can now switch to GNOME from your login screen's session selector."
        echo "To set GNOME as the default desktop environment, please log out and log back in with GNOME selected."
        
        # Ask if user wants to reboot
        read -p "It's recommended to reboot your system. Do you want to reboot now? (y/N): " reboot_choice
        if [[ $reboot_choice =~ ^[Yy]$ ]]; then
            echo "Rebooting system in 5 seconds..."
            sleep 5
            sudo reboot
        fi
    else
        echo "Failed to install $PACKAGE_NAME."
        exit 1
    fi
}

# Main script execution
detect_distro
install_package 