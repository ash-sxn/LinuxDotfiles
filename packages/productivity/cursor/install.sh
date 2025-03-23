#!/bin/bash

# Cursor installation script

# Package information
PACKAGE_NAME="Cursor"
PACKAGE_DESCRIPTION="AI-first code editor based on VSCode"
PACKAGE_DOTFILES_DIR="$HOME/.config/cursor"

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

# Check if Cursor is already installed
is_installed() {
    if command -v cursor &> /dev/null; then
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

# Install Cursor on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Cursor is not available for your architecture."
        return 1
    fi
    
    # Install dependencies
    sudo apt update
    sudo apt install -y wget gnupg apt-transport-https software-properties-common

    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest Cursor .deb package
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Cursor for x86_64 architecture..."
        wget -O cursor.deb "https://download.cursor.sh/linux/appImage/x64/latest"
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Downloading Cursor for ARM64 architecture..."
        wget -O cursor.deb "https://download.cursor.sh/linux/appImage/arm64/latest"
    fi
    
    # Install the package
    if [ -f cursor.deb ]; then
        sudo apt install -y ./cursor.deb
    else
        echo "Failed to download Cursor package."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return $?
}

# Install Cursor on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Cursor is not available for your architecture."
        return 1
    fi
    
    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download latest Cursor .rpm package
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Cursor for x86_64 architecture..."
        wget -O cursor.rpm "https://download.cursor.sh/linux/appImage/x64/latest"
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Downloading Cursor for ARM64 architecture..."
        wget -O cursor.rpm "https://download.cursor.sh/linux/appImage/arm64/latest"
    fi
    
    # Install the package
    if [ -f cursor.rpm ]; then
        if [ "$DISTRO" = "fedora" ]; then
            sudo dnf install -y ./cursor.rpm
        else
            sudo yum install -y ./cursor.rpm
        fi
    else
        echo "Failed to download Cursor package."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return $?
}

# Install Cursor on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Cursor is not available for your architecture."
        return 1
    fi
    
    # Check if yay or paru is installed
    if command -v yay &> /dev/null; then
        echo "Installing Cursor using yay..."
        yay -S --noconfirm cursor-bin
    elif command -v paru &> /dev/null; then
        echo "Installing Cursor using paru..."
        paru -S --noconfirm cursor-bin
    else
        echo "No AUR helper found. Installing using manual AUR method..."
        
        # Install build dependencies
        sudo pacman -S --noconfirm --needed base-devel git
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR" || exit
        
        # Clone AUR package
        git clone https://aur.archlinux.org/cursor-bin.git
        cd cursor-bin || exit
        
        # Build and install package
        makepkg -si --noconfirm
        
        # Clean up
        cd "$HOME" || exit
        rm -rf "$TEMP_DIR"
    fi
    
    return $?
}

# Install Cursor on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Cursor is not available for your architecture."
        return 1
    fi
    
    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download Cursor AppImage
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Cursor AppImage for x86_64 architecture..."
        wget -O cursor "https://download.cursor.sh/linux/appImage/x64/latest"
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Downloading Cursor AppImage for ARM64 architecture..."
        wget -O cursor "https://download.cursor.sh/linux/appImage/arm64/latest"
    fi
    
    # Make AppImage executable
    if [ -f cursor ]; then
        chmod +x cursor
        mkdir -p "$HOME/.local/bin"
        mv cursor "$HOME/.local/bin/"
        
        # Create desktop entry
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor based on VSCode
Exec=$HOME/.local/bin/cursor
Icon=cursor
Type=Application
Categories=Development;IDE;
Keywords=code;editor;ai;vscode;
EOF
        
        echo "Cursor has been installed to $HOME/.local/bin/cursor"
        echo "A desktop entry has been created."
    else
        echo "Failed to download Cursor AppImage."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return 0
}

# Generic installation method using AppImage
install_generic() {
    echo "Installing $PACKAGE_NAME using generic method (AppImage)..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Cursor is not available for your architecture."
        return 1
    fi
    
    # Create temp directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download Cursor AppImage
    if [ "$ARCH_TYPE" = "amd64" ]; then
        echo "Downloading Cursor AppImage for x86_64 architecture..."
        wget -O cursor "https://download.cursor.sh/linux/appImage/x64/latest"
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Downloading Cursor AppImage for ARM64 architecture..."
        wget -O cursor "https://download.cursor.sh/linux/appImage/arm64/latest"
    fi
    
    # Make AppImage executable
    if [ -f cursor ]; then
        chmod +x cursor
        mkdir -p "$HOME/.local/bin"
        mv cursor "$HOME/.local/bin/"
        
        # Create desktop entry
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor based on VSCode
Exec=$HOME/.local/bin/cursor
Icon=cursor
Type=Application
Categories=Development;IDE;
Keywords=code;editor;ai;vscode;
EOF
        
        echo "Cursor has been installed to $HOME/.local/bin/cursor"
        echo "A desktop entry has been created."
        
        # Create icon if necessary
        if [ ! -f "$HOME/.local/share/icons/cursor.png" ]; then
            mkdir -p "$HOME/.local/share/icons"
            # Try to download an icon
            wget -O "$HOME/.local/share/icons/cursor.png" "https://www.cursor.sh/favicon.ico" || true
        fi
    else
        echo "Failed to download Cursor AppImage."
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    return 0
}

# Setup configuration
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Ask if user wants to set up GPT-4 API key
    read -p "Do you want to set up an OpenAI API key for Cursor? (y/N): " setup_api
    if [[ "$setup_api" =~ ^[Yy]$ ]]; then
        read -p "Enter your OpenAI API key: " api_key
        if [ -n "$api_key" ]; then
            # Create or update settings.json
            SETTINGS_FILE="$PACKAGE_DOTFILES_DIR/settings.json"
            
            if [ -f "$SETTINGS_FILE" ]; then
                # Backup existing settings
                cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
                
                # Update API key in settings
                if command -v jq &> /dev/null; then
                    jq --arg key "$api_key" '.["cursor.apiKey"] = $key' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp"
                    mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
                else
                    # Simple approach if jq isn't available
                    if grep -q "cursor.apiKey" "$SETTINGS_FILE"; then
                        sed -i 's/"cursor.apiKey": ".*"/"cursor.apiKey": "'"$api_key"'"/' "$SETTINGS_FILE"
                    else
                        # If the key doesn't exist, add it (this is a simplified approach)
                        sed -i 's/{/{\"cursor.apiKey\": \"'"$api_key"'\",/' "$SETTINGS_FILE"
                    fi
                fi
            else
                # Create new settings file with API key
                echo "{" > "$SETTINGS_FILE"
                echo "  \"cursor.apiKey\": \"$api_key\"" >> "$SETTINGS_FILE"
                echo "}" >> "$SETTINGS_FILE"
            fi
            
            echo "API key has been set in Cursor settings."
        else
            echo "No API key provided. Skipping."
        fi
    else
        echo "Skipping API key setup."
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
        read -p "Do you want to set up Cursor configuration? (Y/n): " config_choice
        if [[ ! $config_choice =~ ^[Nn]$ ]]; then
            setup_config
        fi
    else
        echo "Failed to install $PACKAGE_NAME. Trying generic installation method..."
        install_generic
        
        if is_installed; then
            echo "$PACKAGE_NAME has been successfully installed using the generic method!"
            
            # Ask to set up configuration
            read -p "Do you want to set up Cursor configuration? (Y/n): " config_choice
            if [[ ! $config_choice =~ ^[Nn]$ ]]; then
                setup_config
            fi
        else
            echo "Failed to install $PACKAGE_NAME."
            exit 1
        fi
    fi
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    if ! is_installed; then
        echo "$PACKAGE_NAME is not installed."
        return
    fi
    
    read -p "Are you sure you want to remove Cursor? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo "Removing Cursor..."
        
        # Different uninstallation methods based on how it was installed
        if [ -f /usr/bin/cursor ]; then
            # Installed via package manager
            case $DISTRO_FAMILY in
                debian)
                    sudo apt remove -y cursor
                    ;;
                redhat)
                    if [ "$DISTRO" = "fedora" ]; then
                        sudo dnf remove -y cursor
                    else
                        sudo yum remove -y cursor
                    fi
                    ;;
                arch)
                    if command -v yay &> /dev/null; then
                        yay -Rns --noconfirm cursor-bin
                    elif command -v paru &> /dev/null; then
                        paru -Rns --noconfirm cursor-bin
                    else
                        sudo pacman -Rns --noconfirm cursor-bin
                    fi
                    ;;
                suse)
                    sudo zypper remove -y cursor
                    ;;
            esac
        elif [ -f "$HOME/.local/bin/cursor" ]; then
            # Installed via AppImage
            rm -f "$HOME/.local/bin/cursor"
            rm -f "$HOME/.local/share/applications/cursor.desktop"
            rm -f "$HOME/.local/share/icons/cursor.png"
        fi
        
        # Ask about removing configuration
        read -p "Do you want to remove Cursor configuration files? (y/N): " remove_config
        if [[ $remove_config =~ ^[Yy]$ ]]; then
            # Backup config before removal
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                echo "Backing up Cursor configuration..."
                backup_dir="${PACKAGE_DOTFILES_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
                cp -r "$PACKAGE_DOTFILES_DIR" "$backup_dir"
                echo "Configuration backed up to $backup_dir"
                
                # Remove configuration
                rm -rf "$PACKAGE_DOTFILES_DIR"
            fi
            
            # Remove any other Cursor data
            if [ -d "$HOME/.cursor" ]; then
                rm -rf "$HOME/.cursor"
            fi
            
            echo "Cursor configuration files have been removed."
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