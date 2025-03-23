#!/bin/bash

# Tealdeer installation script (https://github.com/tealdeer-rs/tealdeer)

# Package information
PACKAGE_NAME="Tealdeer"
PACKAGE_DESCRIPTION="A fast implementation of tldr in Rust"
PACKAGE_DOTFILES_DIR="$HOME/.config/tealdeer"

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
    if command -v tldr &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install cargo (Rust package manager) if it's not installed
install_cargo() {
    if ! command -v cargo &> /dev/null; then
        echo "Installing Rust and Cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
}

# Install package on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # First, check if it's available in the repositories (Ubuntu 20.04+ and Debian 11+)
    if apt-cache search --names-only ^tealdeer$ | grep -q tealdeer; then
        sudo apt update
        sudo apt install -y tealdeer
    else
        # Install build dependencies
        sudo apt update
        sudo apt install -y build-essential pkg-config libssl-dev
        
        # Install via cargo
        install_cargo
        cargo install tealdeer
    fi
}

# Install package on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Check if it's available in the repositories (Fedora has it)
    if dnf list tealdeer &> /dev/null; then
        sudo dnf install -y tealdeer
    else
        # Install build dependencies
        sudo dnf install -y gcc openssl-devel
        
        # Install via cargo
        install_cargo
        cargo install tealdeer
    fi
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
    
    # Install from official repos or AUR
    if pacman -Ss ^tealdeer$ | grep -q "^core\|^extra\|^community"; then
        sudo pacman -S --noconfirm tealdeer
    else
        yay -S --noconfirm tealdeer
    fi
}

# Install package on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Check if it's available in the repositories
    if zypper search -x tealdeer | grep -q "^tealdeer "; then
        sudo zypper install -y tealdeer
    else
        # Install build dependencies
        sudo zypper install -y gcc libopenssl-devel
        
        # Install via cargo
        install_cargo
        cargo install tealdeer
    fi
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method via Cargo..."
    
    install_cargo
    cargo install tealdeer
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create default config file if it doesn't exist
    if [ ! -f "$PACKAGE_DOTFILES_DIR/config.toml" ]; then
        cat > "$PACKAGE_DOTFILES_DIR/config.toml" << 'EOF'
[display]
use_pager = false
compact = false

[updates]
auto_update = true
auto_update_interval_hours = 720  # 30 days

[style.command_name]
foreground = "cyan"
background = null
underline = false
bold = true
italic = false

[style.example_text]
foreground = "green"
background = null
underline = false
bold = false
italic = false

[style.example_code]
foreground = "yellow"
background = null
underline = false
bold = false
italic = false

[style.example_variable]
foreground = "magenta"
background = null
underline = false
bold = false
italic = true
EOF
    fi
    
    # Download the latest pages
    echo "Updating tldr pages database..."
    if command -v tldr &> /dev/null; then
        tldr --update
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
            setup_config
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
    
    # Make sure PATH includes ~/.cargo/bin
    if [[ ! "$PATH" =~ "$HOME/.cargo/bin" ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
        # Add to .zshrc if it exists
        if [ -f "$HOME/.zshrc" ]; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi
    
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
    
    # Uninstall based on how it was installed
    if [ -f "$HOME/.cargo/bin/tldr" ]; then
        # Installed via cargo
        cargo uninstall tealdeer
    else
        # Uninstall based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y tealdeer
                ;;
            redhat)
                sudo dnf remove -y tealdeer
                ;;
            arch)
                sudo pacman -Rs --noconfirm tealdeer
                ;;
            suse)
                sudo zypper remove -y tealdeer
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall manually."
                ;;
        esac
    fi
    
    # Backup and remove config files
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        echo "Backing up configuration files..."
        backup_dir="$HOME/.config/backup/tealdeer"
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