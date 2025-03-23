#!/bin/bash

# Alacritty installation script

# Package information
PACKAGE_NAME="Alacritty"
PACKAGE_DESCRIPTION="A cross-platform, GPU-accelerated terminal emulator"
PACKAGE_DOTFILES_DIR="$HOME/.config/alacritty"

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

# Check if Alacritty is already installed
is_installed() {
    if command -v alacritty &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Get system architecture
get_arch() {
    case $(uname -m) in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Install Alacritty on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Check if it's Ubuntu 20.04 or newer
    if [ "$DISTRO" = "ubuntu" ] && [ "$(echo "$VERSION_ID >= 20.04" | bc)" -eq 1 ]; then
        echo "Installing Alacritty from Ubuntu repositories..."
        sudo apt update
        sudo apt install -y alacritty
    else
        # For older versions or non-Ubuntu Debian-based distributions
        echo "Alacritty is not available in the standard repositories for your distribution."
        echo "Installing Alacritty from source..."
        
        # Install dependencies
        sudo apt update
        sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 curl
        
        # Check if Rust is installed
        if ! command -v rustc &> /dev/null; then
            echo "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source $HOME/.cargo/env
        fi
        
        # Clone and build Alacritty
        TEMP_DIR=$(mktemp -d)
        git clone https://github.com/alacritty/alacritty.git "$TEMP_DIR"
        cd "$TEMP_DIR"
        
        # If a tag is provided, check it out
        if [ -n "$1" ]; then
            git checkout "$1"
        fi
        
        # Build and install
        cargo build --release
        
        # Install the binary
        sudo cp target/release/alacritty /usr/local/bin/
        
        # Install desktop entry, terminfo, and other configurations
        sudo mkdir -p /usr/local/share/man/man1
        sudo mkdir -p /usr/local/share/man/man5
        gzip -c extra/man/alacritty.1 | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        gzip -c extra/man/alacritty-msg.1 | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
        gzip -c extra/man/alacritty.5 | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
        gzip -c extra/man/alacritty-bindings.5 | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
        
        sudo cp extra/completions/alacritty.bash /etc/bash_completion.d/alacritty
        sudo cp extra/completions/_alacritty /usr/share/zsh/site-functions/_alacritty
        sudo cp extra/completions/alacritty.fish /usr/share/fish/vendor_completions.d/alacritty.fish
        
        sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
        
        # Clean up temp directory
        cd
        rm -rf "$TEMP_DIR"
    fi
}

# Install Alacritty on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Alacritty is available in Fedora's official repositories
    if [ "$DISTRO" = "fedora" ]; then
        sudo dnf install -y alacritty
    else
        # For other Red Hat based systems
        echo "Alacritty is not available in the standard repositories for your distribution."
        echo "Installing Alacritty from source..."
        
        # Install dependencies
        sudo dnf install -y cmake freetype-devel fontconfig-devel libxcb-devel python3 libxkbcommon-devel git
        
        # Check if Rust is installed
        if ! command -v rustc &> /dev/null; then
            echo "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source $HOME/.cargo/env
        fi
        
        # Clone and build Alacritty
        TEMP_DIR=$(mktemp -d)
        git clone https://github.com/alacritty/alacritty.git "$TEMP_DIR"
        cd "$TEMP_DIR"
        
        # If a tag is provided, check it out
        if [ -n "$1" ]; then
            git checkout "$1"
        fi
        
        # Build and install
        cargo build --release
        
        # Install the binary
        sudo cp target/release/alacritty /usr/local/bin/
        
        # Install desktop entry, terminfo, and other configurations
        sudo mkdir -p /usr/local/share/man/man1
        sudo mkdir -p /usr/local/share/man/man5
        gzip -c extra/man/alacritty.1 | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        gzip -c extra/man/alacritty-msg.1 | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
        gzip -c extra/man/alacritty.5 | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
        gzip -c extra/man/alacritty-bindings.5 | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
        
        sudo mkdir -p /etc/bash_completion.d
        sudo cp extra/completions/alacritty.bash /etc/bash_completion.d/alacritty
        
        sudo mkdir -p /usr/share/zsh/site-functions
        sudo cp extra/completions/_alacritty /usr/share/zsh/site-functions/_alacritty
        
        sudo mkdir -p /usr/share/fish/vendor_completions.d
        sudo cp extra/completions/alacritty.fish /usr/share/fish/vendor_completions.d/alacritty.fish
        
        sudo mkdir -p /usr/share/pixmaps
        sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
        
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
        
        # Clean up temp directory
        cd
        rm -rf "$TEMP_DIR"
    fi
}

# Install Alacritty on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    sudo pacman -S --noconfirm alacritty
}

# Install Alacritty on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Check if Alacritty is in the standard repositories
    if sudo zypper search -x alacritty | grep -q "^i\|^i+"; then
        sudo zypper install -y alacritty
    else
        echo "Alacritty is not available in the standard repositories for your distribution."
        echo "Installing Alacritty from source..."
        
        # Install dependencies
        sudo zypper install -y cmake freetype2-devel fontconfig-devel libxcb-devel python3 git
        
        # Check if Rust is installed
        if ! command -v rustc &> /dev/null; then
            echo "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source $HOME/.cargo/env
        fi
        
        # Clone and build Alacritty
        TEMP_DIR=$(mktemp -d)
        git clone https://github.com/alacritty/alacritty.git "$TEMP_DIR"
        cd "$TEMP_DIR"
        
        # If a tag is provided, check it out
        if [ -n "$1" ]; then
            git checkout "$1"
        fi
        
        # Build and install
        cargo build --release
        
        # Install the binary
        sudo cp target/release/alacritty /usr/local/bin/
        
        # Install desktop entry, terminfo, and other configurations
        sudo mkdir -p /usr/local/share/man/man1
        sudo mkdir -p /usr/local/share/man/man5
        gzip -c extra/man/alacritty.1 | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        gzip -c extra/man/alacritty-msg.1 | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
        gzip -c extra/man/alacritty.5 | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
        gzip -c extra/man/alacritty-bindings.5 | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
        
        sudo mkdir -p /etc/bash_completion.d
        sudo cp extra/completions/alacritty.bash /etc/bash_completion.d/alacritty
        
        sudo mkdir -p /usr/share/zsh/site-functions
        sudo cp extra/completions/_alacritty /usr/share/zsh/site-functions/_alacritty
        
        sudo mkdir -p /usr/share/fish/vendor_completions.d
        sudo cp extra/completions/alacritty.fish /usr/share/fish/vendor_completions.d/alacritty.fish
        
        sudo mkdir -p /usr/share/pixmaps
        sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
        
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
        
        # Clean up temp directory
        cd
        rm -rf "$TEMP_DIR"
    fi
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method via Rust/Cargo..."
    
    # Check if Rust is installed
    if ! command -v rustc &> /dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    fi
    
    echo "Please install the following dependencies manually before continuing:"
    echo "- cmake"
    echo "- pkg-config"
    echo "- freetype development files"
    echo "- fontconfig development files"
    echo "- xcb development files"
    read -p "Have you installed the dependencies? (y/N): " deps_installed
    if [[ ! $deps_installed =~ ^[Yy]$ ]]; then
        echo "Please install the dependencies and run this script again."
        exit 1
    fi
    
    # Clone and build Alacritty
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/alacritty/alacritty.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # If a tag is provided, check it out
    if [ -n "$1" ]; then
        git checkout "$1"
    fi
    
    # Build and install
    cargo build --release
    
    # Install the binary
    mkdir -p $HOME/.local/bin
    cp target/release/alacritty $HOME/.local/bin/
    
    # Add to PATH if not already there
    if ! echo $PATH | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Install configurations
    mkdir -p $HOME/.local/share/man/man1
    mkdir -p $HOME/.local/share/man/man5
    mkdir -p $HOME/.bash_completion
    mkdir -p $HOME/.zsh/completion
    mkdir -p $HOME/.config/fish/completions
    
    gzip -c extra/man/alacritty.1 > $HOME/.local/share/man/man1/alacritty.1.gz
    gzip -c extra/man/alacritty-msg.1 > $HOME/.local/share/man/man1/alacritty-msg.1.gz
    gzip -c extra/man/alacritty.5 > $HOME/.local/share/man/man5/alacritty.5.gz
    gzip -c extra/man/alacritty-bindings.5 > $HOME/.local/share/man/man5/alacritty-bindings.5.gz
    
    cp extra/completions/alacritty.bash $HOME/.bash_completion/alacritty
    cp extra/completions/_alacritty $HOME/.zsh/completion/
    cp extra/completions/alacritty.fish $HOME/.config/fish/completions/
    
    mkdir -p $HOME/.local/share/applications
    cp extra/linux/Alacritty.desktop $HOME/.local/share/applications/
    
    # Update PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Clean up temp directory
    cd
    rm -rf "$TEMP_DIR"
    
    echo "Alacritty has been installed to $HOME/.local/bin/alacritty"
    echo "You may need to log out and log back in for the changes to take effect."
}

# Setup basic configuration files
setup_basic_config() {
    echo "Setting up basic Alacritty configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create Alacritty YAML configuration file
    cat > "$PACKAGE_DOTFILES_DIR/alacritty.yml" << 'EOF'
# Alacritty configuration file

# Window configuration
window:
  dimensions:
    columns: 90
    lines: 30
  padding:
    x: 5
    y: 5
  decorations: full
  dynamic_title: true
  startup_mode: Windowed
  opacity: 0.95
  
# Scrolling settings
scrolling:
  history: 10000
  multiplier: 3

# Font configuration
font:
  normal:
    family: monospace
    style: Regular
  bold:
    family: monospace
    style: Bold
  italic:
    family: monospace
    style: Italic
  bold_italic:
    family: monospace
    style: Bold Italic
  size: 11.0
  offset:
    x: 0
    y: 0
  glyph_offset:
    x: 0
    y: 0

# Colors (Nord theme)
colors:
  primary:
    background: '#2e3440'
    foreground: '#d8dee9'
    dim_foreground: '#a5abb6'
  cursor:
    text: '#2e3440'
    cursor: '#d8dee9'
  vi_mode_cursor:
    text: '#2e3440'
    cursor: '#d8dee9'
  selection:
    text: CellForeground
    background: '#4c566a'
  normal:
    black:   '#3b4252'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#88c0d0'
    white:   '#e5e9f0'
  bright:
    black:   '#4c566a'
    red:     '#bf616a'
    green:   '#a3be8c'
    yellow:  '#ebcb8b'
    blue:    '#81a1c1'
    magenta: '#b48ead'
    cyan:    '#8fbcbb'
    white:   '#eceff4'
  dim:
    black:   '#373e4d'
    red:     '#94545d'
    green:   '#809575'
    yellow:  '#b29e75'
    blue:    '#68809a'
    magenta: '#8c738c'
    cyan:    '#6d96a5'
    white:   '#aeb3bb'

# Cursor configuration
cursor:
  style:
    shape: Block
    blinking: On
  thickness: 0.15
  unfocused_hollow: true
  blink_interval: 750

# Live config reload
live_config_reload: true

# Key bindings
key_bindings:
  - { key: V,              mods: Control|Shift, action: Paste            }
  - { key: C,              mods: Control|Shift, action: Copy             }
  - { key: Insert,         mods: Shift,         action: PasteSelection   }
  - { key: Key0,           mods: Control,       action: ResetFontSize    }
  - { key: Equals,         mods: Control,       action: IncreaseFontSize }
  - { key: Plus,           mods: Control,       action: IncreaseFontSize }
  - { key: Minus,          mods: Control,       action: DecreaseFontSize }
  - { key: F11,            mods: None,          action: ToggleFullscreen }
  - { key: Paste,          mods: None,          action: Paste            }
  - { key: Copy,           mods: None,          action: Copy             }
  - { key: L,              mods: Control,       action: ClearLogNotice   }
  - { key: L,              mods: Control,       chars: "\x0c"            }
  - { key: PageUp,         mods: None,          action: ScrollPageUp     }
  - { key: PageDown,       mods: None,          action: ScrollPageDown   }
  - { key: Home,           mods: Shift,         action: ScrollToTop      }
  - { key: End,            mods: Shift,         action: ScrollToBottom   }
  - { key: N,              mods: Control|Shift, action: SpawnNewInstance }

# Mouse configuration
mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }
  hide_when_typing: false

# Shell configuration
shell:
  program: /bin/bash
  args:
    - --login

# Working directory
working_directory: None
EOF
    
    echo "Basic Alacritty configuration created at $PACKAGE_DOTFILES_DIR/alacritty.yml"
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Backup existing configuration if it exists
    if [ -f "$PACKAGE_DOTFILES_DIR/alacritty.yml" ] || [ -f "$PACKAGE_DOTFILES_DIR/alacritty.toml" ]; then
        echo "Backing up existing Alacritty configuration..."
        backup_dir="$HOME/.config/alacritty-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$PACKAGE_DOTFILES_DIR"/* "$backup_dir" 2>/dev/null || true
        echo "Backup created at $backup_dir"
    fi
    
    # Ask for configuration preference
    echo "Select Alacritty configuration type:"
    echo "1. Basic configuration (with nice defaults)"
    echo "2. No configuration (I'll set it up myself)"
    read -p "Choice [1-2]: " config_choice
    
    case $config_choice in
        1)
            setup_basic_config
            ;;
        2)
            echo "No configuration set up. You can configure Alacritty by editing $PACKAGE_DOTFILES_DIR/alacritty.yml"
            mkdir -p "$PACKAGE_DOTFILES_DIR"
            ;;
        *)
            echo "Invalid choice. Setting up basic configuration."
            setup_basic_config
            ;;
    esac
    
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
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        
        # Ask to set up configuration
        read -p "Do you want to set up Alacritty configuration? (Y/n): " config_choice
        if [[ ! $config_choice =~ ^[Nn]$ ]]; then
            setup_config
        fi
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
    
    # Ask for confirmation
    read -p "Are you sure you want to remove Alacritty? (y/N): " choice
    if [[ ! $choice =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        return
    fi
    
    # Check the installation path to determine uninstallation method
    alacritty_path=$(which alacritty)
    
    if [[ "$alacritty_path" == "/usr/bin/alacritty" ]]; then
        # Installed via package manager
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y alacritty
                ;;
            redhat)
                sudo dnf remove -y alacritty
                ;;
            arch)
                sudo pacman -Rs --noconfirm alacritty
                ;;
            suse)
                sudo zypper remove -y alacritty
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall Alacritty manually."
                ;;
        esac
    elif [[ "$alacritty_path" == "/usr/local/bin/alacritty" ]]; then
        # Installed from source to /usr/local
        sudo rm -f /usr/local/bin/alacritty
        sudo rm -f /usr/local/share/man/man1/alacritty.1.gz
        sudo rm -f /usr/local/share/man/man1/alacritty-msg.1.gz
        sudo rm -f /usr/local/share/man/man5/alacritty.5.gz
        sudo rm -f /usr/local/share/man/man5/alacritty-bindings.5.gz
        sudo rm -f /etc/bash_completion.d/alacritty
        sudo rm -f /usr/share/zsh/site-functions/_alacritty
        sudo rm -f /usr/share/fish/vendor_completions.d/alacritty.fish
        sudo rm -f /usr/share/pixmaps/Alacritty.svg
        sudo rm -f /usr/share/applications/Alacritty.desktop
    elif [[ "$alacritty_path" == "$HOME/.local/bin/alacritty" ]]; then
        # Installed to user's local bin
        rm -f "$HOME/.local/bin/alacritty"
        rm -f "$HOME/.local/share/man/man1/alacritty.1.gz"
        rm -f "$HOME/.local/share/man/man1/alacritty-msg.1.gz"
        rm -f "$HOME/.local/share/man/man5/alacritty.5.gz"
        rm -f "$HOME/.local/share/man/man5/alacritty-bindings.5.gz"
        rm -f "$HOME/.bash_completion/alacritty"
        rm -f "$HOME/.zsh/completion/_alacritty"
        rm -f "$HOME/.config/fish/completions/alacritty.fish"
        rm -f "$HOME/.local/share/applications/Alacritty.desktop"
    else
        echo "Unknown installation method. Trying common uninstallation methods..."
        # Try to remove from common locations
        sudo rm -f /usr/bin/alacritty /usr/local/bin/alacritty "$HOME/.local/bin/alacritty"
    fi
    
    # Ask to remove configuration files
    read -p "Do you want to remove Alacritty configuration files? (y/N): " config_choice
    if [[ $config_choice =~ ^[Yy]$ ]]; then
        echo "Backing up configuration before removal..."
        backup_dir="$HOME/.config/alacritty-backup-$(date +%Y%m%d-%H%M%S)"
        if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
            mkdir -p "$backup_dir"
            cp -r "$PACKAGE_DOTFILES_DIR"/* "$backup_dir" 2>/dev/null || true
        fi
        
        # Remove Alacritty configuration directory
        rm -rf "$PACKAGE_DOTFILES_DIR"
        
        echo "Alacritty configuration has been removed. Backup created at $backup_dir"
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