#!/bin/bash

# Zsh and Oh My Zsh installation script

# Package information
PACKAGE_NAME="Zsh with Oh My Zsh"
PACKAGE_DESCRIPTION="Zsh is a powerful shell with improved features and Oh My Zsh is a framework for managing Zsh configuration"
PACKAGE_DOTFILES_DIR="$HOME/.zsh"

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

# Check if Zsh is already installed
is_installed() {
    if command -v zsh &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Check if Oh My Zsh is already installed
is_omz_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        return 0  # true, Oh My Zsh is installed
    else
        return 1  # false, Oh My Zsh is not installed
    fi
}

# Install Zsh on Debian-based systems
install_zsh_debian() {
    echo "Installing Zsh on Debian-based system..."
    
    sudo apt update
    sudo apt install -y zsh curl git
    
    # Return success if zsh is installed
    if command -v zsh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Zsh on Red Hat-based systems
install_zsh_redhat() {
    echo "Installing Zsh on Red Hat-based system..."
    
    sudo dnf install -y zsh curl git
    
    # Return success if zsh is installed
    if command -v zsh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Zsh on Arch-based systems
install_zsh_arch() {
    echo "Installing Zsh on Arch-based system..."
    
    sudo pacman -S --noconfirm zsh curl git
    
    # Return success if zsh is installed
    if command -v zsh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Zsh on SUSE-based systems
install_zsh_suse() {
    echo "Installing Zsh on SUSE-based system..."
    
    sudo zypper install -y zsh curl git
    
    # Return success if zsh is installed
    if command -v zsh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Generic installation function for unsupported distributions
install_zsh_generic() {
    echo "Installing Zsh on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "Zsh is available on most Linux distributions."
    echo "Please install Zsh using your distribution's package manager."
    
    return 1  # Return failure
}

# Install Oh My Zsh
install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    
    # Backup existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        echo "Backing up existing .zshrc..."
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Install Oh My Zsh
    echo "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    if [ $? -ne 0 ]; then
        echo "Failed to install Oh My Zsh."
        return 1
    fi
    
    echo "Oh My Zsh has been installed successfully!"
    return 0
}

# Set Zsh as default shell
set_zsh_as_default() {
    echo "Setting Zsh as the default shell..."
    
    # Get the path to zsh
    ZSH_PATH=$(which zsh)
    
    # Check if zsh is already the default shell
    if [ "$SHELL" = "$ZSH_PATH" ]; then
        echo "Zsh is already the default shell."
        return 0
    fi
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    
    # Change the default shell
    echo "Changing default shell to Zsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    
    if [ $? -ne 0 ]; then
        echo "Failed to set Zsh as the default shell."
        echo "You can manually set it later with: chsh -s $(which zsh)"
        return 1
    fi
    
    echo "Zsh has been set as the default shell."
    echo "Please log out and log back in for the changes to take effect."
    return 0
}

# Install plugins (optional)
install_plugins() {
    echo "Installing recommended Zsh plugins..."
    
    # Zsh autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # Zsh syntax highlighting
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    # Check if plugins are already in .zshrc
    if ! grep -q "zsh-autosuggestions\|zsh-syntax-highlighting" "$HOME/.zshrc"; then
        # Update plugins line in .zshrc
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    fi
    
    echo "Zsh plugins have been installed."
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Install Oh My Zsh if not already installed
    if ! is_omz_installed; then
        install_oh_my_zsh
    fi
    
    # Install plugins
    install_plugins
    
    # Set Zsh as default shell
    set_zsh_as_default
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    # First check if Zsh is already installed
    if is_installed; then
        echo "Zsh is already installed."
        
        # Check if Oh My Zsh is also installed
        if is_omz_installed; then
            echo "Oh My Zsh is also already installed."
            read -p "Do you want to reinstall Oh My Zsh? (y/N): " choice
            if [[ $choice =~ ^[Yy]$ ]]; then
                install_oh_my_zsh
                setup_config
            else
                echo "Skipping Oh My Zsh installation."
            fi
            return
        else
            echo "Oh My Zsh is not installed."
            read -p "Do you want to install Oh My Zsh? (Y/n): " choice
            if [[ ! $choice =~ ^[Nn]$ ]]; then
                install_oh_my_zsh
                setup_config
            else
                echo "Skipping Oh My Zsh installation."
            fi
            return
        fi
    fi
    
    # Install Zsh based on distribution family
    case $DISTRO_FAMILY in
        debian)
            install_zsh_debian
            ;;
        redhat)
            install_zsh_redhat
            ;;
        arch)
            install_zsh_arch
            ;;
        suse)
            install_zsh_suse
            ;;
        *)
            install_zsh_generic
            ;;
    esac
    
    if is_installed; then
        echo "Zsh has been successfully installed!"
        
        # Ask if user wants to install Oh My Zsh
        read -p "Do you want to install Oh My Zsh? (Y/n): " choice
        if [[ ! $choice =~ ^[Nn]$ ]]; then
            install_oh_my_zsh
            setup_config
        else
            echo "Skipping Oh My Zsh installation."
        fi
    else
        echo "Failed to install Zsh."
        exit 1
    fi
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    # Check if Zsh is installed
    if ! is_installed; then
        echo "Zsh is not installed."
        return
    fi
    
    # Check if Oh My Zsh is installed
    if is_omz_installed; then
        read -p "Do you want to remove Oh My Zsh? (y/N): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            echo "Removing Oh My Zsh..."
            
            # Backup .zshrc if it exists
            if [ -f "$HOME/.zshrc" ]; then
                cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
            fi
            
            # Remove Oh My Zsh
            rm -rf "$HOME/.oh-my-zsh"
            
            echo "Oh My Zsh has been removed."
        fi
    fi
    
    # Ask to remove Zsh
    read -p "Do you want to remove Zsh? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Set default shell back to bash if zsh is current default
        if [ "$SHELL" = "$(which zsh)" ]; then
            echo "Setting default shell back to bash..."
            sudo chsh -s "$(which bash)" "$USER"
            echo "Please log out and log back in for the changes to take effect."
        fi
        
        # Remove Zsh based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y zsh
                ;;
            redhat)
                sudo dnf remove -y zsh
                ;;
            arch)
                sudo pacman -Rs --noconfirm zsh
                ;;
            suse)
                sudo zypper remove -y zsh
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall Zsh manually."
                ;;
        esac
        
        echo "Zsh has been removed."
    fi
    
    # Remove config directory
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        read -p "Do you want to remove Zsh configuration directory? (y/N): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            rm -rf "$PACKAGE_DOTFILES_DIR"
            echo "Zsh configuration directory has been removed."
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