#!/bin/bash

# Go Programming Language installation script

# Package information
PACKAGE_NAME="Go Programming Language"
PACKAGE_DESCRIPTION="Go is an open source programming language designed for building simple, fast, and reliable software"
PACKAGE_DOTFILES_DIR="$HOME/.config/go"

# Latest stable Go version
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
GO_VERSION=${GO_VERSION:-"go1.21.6"} # Fallback version if curl fails

# Go installation paths
GO_INSTALL_PATH="/usr/local/go"
GO_PATH="$HOME/go"

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

# Check if Go is already installed
is_installed() {
    if command -v go &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Get architecture
get_arch() {
    local ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7*)
            echo "armv6l"
            ;;
        *)
            echo "amd64"  # Default to amd64
            ;;
    esac
}

# Install Go from official package
install_from_official() {
    local ARCH=$(get_arch)
    local GO_DOWNLOAD_URL="https://dl.google.com/go/${GO_VERSION}.linux-${ARCH}.tar.gz"
    
    echo "Downloading Go from $GO_DOWNLOAD_URL..."
    
    # Download Go
    wget -q -O "/tmp/go.tar.gz" "$GO_DOWNLOAD_URL"
    
    if [ $? -ne 0 ]; then
        echo "Failed to download Go."
        return 1
    fi
    
    # Remove previous installation if it exists
    if [ -d "$GO_INSTALL_PATH" ]; then
        echo "Removing previous Go installation..."
        sudo rm -rf "$GO_INSTALL_PATH"
    fi
    
    # Extract Go
    echo "Extracting Go..."
    sudo tar -C /usr/local -xzf "/tmp/go.tar.gz"
    
    if [ $? -ne 0 ]; then
        echo "Failed to extract Go."
        return 1
    fi
    
    # Create GOPATH if it doesn't exist
    if [ ! -d "$GO_PATH" ]; then
        mkdir -p "$GO_PATH/bin" "$GO_PATH/src" "$GO_PATH/pkg"
    fi
    
    # Clean up
    rm -f "/tmp/go.tar.gz"
    
    echo "Go has been installed to $GO_INSTALL_PATH"
    return 0
}

# Install Go on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Install dependencies
    sudo apt update
    sudo apt install -y wget curl git build-essential
    
    # Install Go from official package
    install_from_official
    
    return $?
}

# Install Go on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Install dependencies
    sudo dnf install -y wget curl git gcc gcc-c++
    
    # Install Go from official package
    install_from_official
    
    return $?
}

# Install Go on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Option 1: Install from official repos
    echo "Installing Go from official repositories..."
    sudo pacman -S --noconfirm go
    
    # Create GOPATH if it doesn't exist
    if [ ! -d "$GO_PATH" ]; then
        mkdir -p "$GO_PATH/bin" "$GO_PATH/src" "$GO_PATH/pkg"
    fi
    
    return 0
}

# Install Go on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Install dependencies
    sudo zypper install -y wget curl git gcc gcc-c++
    
    # Install Go from official package
    install_from_official
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    
    # Install Go from official package
    install_from_official
    
    return $?
}

# Setup environment variables
setup_env_vars() {
    local SHELL_PROFILE=""
    
    # Detect the current shell
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_PROFILE="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_PROFILE="$HOME/.bash_profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    else
        # Default to bashrc
        SHELL_PROFILE="$HOME/.bashrc"
    fi
    
    # Check if Go is already in PATH
    if ! grep -q "export PATH=.*go/bin" "$SHELL_PROFILE"; then
        echo "Adding Go to PATH in $SHELL_PROFILE..."
        
        echo "" >> "$SHELL_PROFILE"
        echo "# Go programming language" >> "$SHELL_PROFILE"
        echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> "$SHELL_PROFILE"
        echo "export GOPATH=\$HOME/go" >> "$SHELL_PROFILE"
    fi
    
    # Source the profile
    source "$SHELL_PROFILE" || true
    
    echo "Go environment variables have been set up."
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Setup environment variables
    setup_env_vars
    
    # Install commonly used Go tools
    echo "Installing useful Go tools..."
    
    # Ensure go binary is in PATH for this session
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    export GOPATH=$HOME/go
    
    # goimports - updates imports and formats code like gofmt
    go install golang.org/x/tools/cmd/goimports@latest
    
    # golint - linter for Go
    go install golang.org/x/lint/golint@latest
    
    # staticcheck - comprehensive static analyzer
    go install honnef.co/go/tools/cmd/staticcheck@latest
    
    # godoc - documentation server
    go install golang.org/x/tools/cmd/godoc@latest
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        current_version=$(go version | awk '{print $3}')
        echo "$PACKAGE_NAME is already installed ($current_version)."
        read -p "Do you want to reinstall it to the latest version ($GO_VERSION)? (y/N): " choice
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
        go version
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
    
    read -p "Are you sure you want to uninstall Go? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        return
    fi
    
    # Remove Go based on distribution family
    case $DISTRO_FAMILY in
        arch)
            sudo pacman -Rs --noconfirm go
            ;;
        *)
            # For most distributions, just remove the Go directory
            sudo rm -rf "$GO_INSTALL_PATH"
            ;;
    esac
    
    # Remove GOPATH if requested
    read -p "Do you want to remove your GOPATH ($GO_PATH)? This will delete all your Go projects and packages. (y/N): " remove_gopath
    if [[ $remove_gopath =~ ^[Yy]$ ]]; then
        rm -rf "$GO_PATH"
        echo "GOPATH ($GO_PATH) has been removed."
    fi
    
    # Remove environment variables from shell profile
    local SHELL_PROFILE=""
    
    # Detect the current shell
    if [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_PROFILE="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_PROFILE="$HOME/.bash_profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    else
        # Default to bashrc
        SHELL_PROFILE="$HOME/.bashrc"
    fi
    
    # Remove Go paths from shell profile
    if [ -f "$SHELL_PROFILE" ]; then
        sed -i '/# Go programming language/d' "$SHELL_PROFILE"
        sed -i '/export PATH=.*go\/bin/d' "$SHELL_PROFILE"
        sed -i '/export GOPATH=.*go/d' "$SHELL_PROFILE"
        echo "Removed Go environment variables from $SHELL_PROFILE."
    fi
    
    # Remove config directory
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        rm -rf "$PACKAGE_DOTFILES_DIR"
        echo "Removed Go configuration directory."
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