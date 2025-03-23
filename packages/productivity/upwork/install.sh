#!/bin/bash

# Upwork installation script

# Package information
PACKAGE_NAME="Upwork"
PACKAGE_DESCRIPTION="Desktop application for the Upwork freelancing platform"
PACKAGE_DOTFILES_DIR="$HOME/.config/Upwork"

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

# Check if Upwork is already installed
is_installed() {
    if command -v upwork &> /dev/null || [ -f "/usr/bin/upwork" ] || [ -f "/usr/local/bin/upwork" ] || [ -f "$HOME/.local/bin/upwork" ]; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Get system architecture
get_arch() {
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64)
            ARCH_TYPE="amd64"
            ;;
        aarch64|arm64)
            ARCH_TYPE="arm64"
            ;;
        *)
            ARCH_TYPE="unsupported"
            ;;
    esac
    
    echo "System architecture: $ARCH_TYPE"
}

# Install Upwork on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Upwork is not available for your architecture."
        return 1
    fi
    
    # Install dependencies
    sudo apt update
    sudo apt install -y wget gnupg apt-transport-https

    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest Upwork .deb package
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Upwork for x86_64 architecture..."
        wget -O upwork.deb "https://upwork-usw2-desktopapp.upwork.com/binaries/v5_9_0_1/upwork_5.9.0.1_amd64.deb"
    else
        echo "Upwork desktop application may not be available for your architecture. The .deb package is only for amd64."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        
        echo "You can try using the web version at https://www.upwork.com/ab/account-security/login"
        return 1
    fi
    
    # Install the package
    if [ -f upwork.deb ]; then
        sudo apt install -y ./upwork.deb
    else
        echo "Failed to download Upwork package."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return $?
}

# Install Upwork on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Upwork is not available for your architecture."
        return 1
    fi
    
    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest Upwork .rpm package
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Upwork for x86_64 architecture..."
        wget -O upwork.rpm "https://upwork-usw2-desktopapp.upwork.com/binaries/v5_9_0_1/upwork-5.9.0.1-1fc43.x86_64.rpm"
    else
        echo "Upwork desktop application may not be available for your architecture. The .rpm package is only for x86_64."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        
        echo "You can try using the web version at https://www.upwork.com/ab/account-security/login"
        return 1
    fi
    
    # Install the package
    if [ -f upwork.rpm ]; then
        if [ "$DISTRO" = "fedora" ]; then
            sudo dnf install -y ./upwork.rpm
        else
            sudo yum install -y ./upwork.rpm
        fi
    else
        echo "Failed to download Upwork package."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return $?
}

# Install Upwork on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Upwork is not available for your architecture."
        return 1
    fi
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Check if yay or paru is installed
        if command -v yay &> /dev/null; then
            echo "Installing Upwork using yay..."
            yay -S --noconfirm upwork-bin
        elif command -v paru &> /dev/null; then
            echo "Installing Upwork using paru..."
            paru -S --noconfirm upwork-bin
        else
            echo "No AUR helper found. Installing using manual AUR method..."
            
            # Install build dependencies
            sudo pacman -S --noconfirm --needed base-devel git
            
            # Create temporary directory
            TEMP_DIR=$(mktemp -d)
            cd "$TEMP_DIR" || exit
            
            # Clone AUR package
            git clone https://aur.archlinux.org/upwork-bin.git
            cd upwork-bin || exit
            
            # Build and install package
            makepkg -si --noconfirm
            
            # Clean up
            cd "$HOME" || exit
            rm -rf "$TEMP_DIR"
        fi
    else
        echo "Upwork desktop application may not be available for your architecture."
        echo "You can try using the web version at https://www.upwork.com/ab/account-security/login"
        return 1
    fi
    
    return $?
}

# Install Upwork on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Upwork is not available for your architecture."
        return 1
    fi
    
    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest Upwork .rpm package
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Upwork for x86_64 architecture..."
        wget -O upwork.rpm "https://upwork-usw2-desktopapp.upwork.com/binaries/v5_9_0_1/upwork-5.9.0.1-1fc43.x86_64.rpm"
    else
        echo "Upwork desktop application may not be available for your architecture. The .rpm package is only for x86_64."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        
        echo "You can try using the web version at https://www.upwork.com/ab/account-security/login"
        return 1
    fi
    
    # Install the package
    if [ -f upwork.rpm ]; then
        sudo zypper install -y ./upwork.rpm
    else
        echo "Failed to download Upwork package."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return $?
}

# Generic installation method using AppImage (if available)
install_generic() {
    echo "Installing $PACKAGE_NAME using generic method..."
    get_arch
    
    # Upwork doesn't provide an official AppImage, but we can suggest the web version
    echo "Upwork doesn't provide an official generic Linux installer."
    echo "Please use the web version at https://www.upwork.com/ab/account-security/login"
    echo "Would you like to create a desktop shortcut for the Upwork website? (y/N)"
    read -r create_shortcut
    
    if [[ "$create_shortcut" =~ ^[Yy]$ ]]; then
        # Create desktop shortcut for Upwork website
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/upwork-web.desktop" << EOF
[Desktop Entry]
Name=Upwork (Web)
Comment=Access Upwork via web browser
Exec=xdg-open https://www.upwork.com/ab/account-security/login
Icon=web-browser
Type=Application
Categories=Network;Office;
Keywords=upwork;freelance;work;
EOF
        
        echo "Desktop shortcut created for Upwork web version."
        return 0
    else
        return 1
    fi
}

# Setup configuration
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # There's not much configuration to set up for Upwork
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
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
            read -p "Do you want to set up/update the configuration? (y/N): " config_choice
            if [[ $config_choice =~ ^[Yy]$ ]]; then
                setup_config
            fi
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
            echo "Unsupported distribution. Trying generic installation method..."
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        
        # Ask to set up configuration
        read -p "Do you want to set up Upwork configuration? (Y/n): " config_choice
        if [[ ! $config_choice =~ ^[Nn]$ ]]; then
            setup_config
        fi
    else
        echo "Failed to install $PACKAGE_NAME. Trying generic installation method..."
        install_generic
    fi
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    if ! is_installed; then
        echo "$PACKAGE_NAME is not installed."
        return
    fi
    
    read -p "Are you sure you want to remove Upwork? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo "Removing Upwork..."
        
        # Different uninstallation methods based on distribution
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y upwork
                sudo apt autoremove -y
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y upwork
                else
                    sudo yum remove -y upwork
                fi
                ;;
            arch)
                if command -v yay &> /dev/null; then
                    yay -Rns --noconfirm upwork-bin
                elif command -v paru &> /dev/null; then
                    paru -Rns --noconfirm upwork-bin
                else
                    sudo pacman -Rns --noconfirm upwork-bin
                fi
                ;;
            suse)
                sudo zypper remove -y upwork
                ;;
        esac
        
        # Remove web shortcut if it exists
        if [ -f "$HOME/.local/share/applications/upwork-web.desktop" ]; then
            rm -f "$HOME/.local/share/applications/upwork-web.desktop"
            echo "Removed Upwork web shortcut."
        fi
        
        # Ask about removing configuration
        read -p "Do you want to remove Upwork configuration files? (y/N): " remove_config
        if [[ $remove_config =~ ^[Yy]$ ]]; then
            # Backup config before removal
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                echo "Backing up Upwork configuration..."
                backup_dir="${PACKAGE_DOTFILES_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
                cp -r "$PACKAGE_DOTFILES_DIR" "$backup_dir"
                echo "Configuration backed up to $backup_dir"
                
                # Remove configuration
                rm -rf "$PACKAGE_DOTFILES_DIR"
            fi
            
            # Remove any other Upwork data
            if [ -d "$HOME/.Upwork" ]; then
                rm -rf "$HOME/.Upwork"
            fi
            
            echo "Upwork configuration files have been removed."
        fi
        
        echo "$PACKAGE_NAME has been uninstalled."
    else
        echo "Uninstallation cancelled."
    fi
}

# Parse command line arguments
if [ "$1" == "uninstall" ]; then
    detect_distro
    uninstall_package
else
    detect_distro
    install_package
fi 