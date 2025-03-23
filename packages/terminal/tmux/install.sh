#!/bin/bash

# Tmux installation script

# Package information
PACKAGE_NAME="Tmux"
PACKAGE_DESCRIPTION="Terminal multiplexer that allows multiple terminal sessions within a single window"
PACKAGE_DOTFILES_DIR="$HOME/.config/tmux"

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

# Check if Tmux is already installed
is_installed() {
    if command -v tmux &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install Tmux on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    sudo apt update
    sudo apt install -y tmux
    
    return $?
}

# Install Tmux on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    sudo dnf install -y tmux
    
    return $?
}

# Install Tmux on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    sudo pacman -S --noconfirm tmux
    
    return $?
}

# Install Tmux on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    sudo zypper install -y tmux
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "Tmux is available on most Linux distributions."
    echo "Please install Tmux using your distribution's package manager."
    
    return 1  # Return failure
}

# Install Tmux plugin manager (TPM)
install_tpm() {
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    
    if [ ! -d "$TPM_DIR" ]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo "TPM installed to $TPM_DIR"
    else
        echo "Tmux Plugin Manager is already installed."
    fi
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create or backup .tmux.conf
    if [ -f "$HOME/.tmux.conf" ]; then
        echo "Backing up existing .tmux.conf..."
        cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Install Tmux Plugin Manager
    install_tpm
    
    # Create a basic tmux configuration
    echo "Creating basic tmux configuration..."
    cat > "$HOME/.tmux.conf" << 'EOF'
# Set prefix to Ctrl-a (instead of Ctrl-b)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Improve colors
set -g default-terminal "screen-256color"

# Set scrollback buffer to 10000
set -g history-limit 10000

# Use vim keybindings in copy mode
setw -g mode-keys vi

# Enable mouse mode
set -g mouse on

# Splitting panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Reload tmux configuration
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Automatically renumber windows
set -g renumber-windows on

# Status bar configuration
set -g status-style fg=white,bg=black
set -g window-status-current-style fg=white,bold,bg=colour27
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green](#S) '
set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=white]%H:%M#[default]'

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
    
    echo "Configuration setup complete!"
    echo "You can reload the tmux configuration with: tmux source-file ~/.tmux.conf"
    echo "Or from within tmux by pressing <prefix> r"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        current_version=$(tmux -V | cut -d ' ' -f2)
        echo "$PACKAGE_NAME is already installed (version $current_version)."
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
        new_version=$(tmux -V | cut -d ' ' -f2)
        echo "Version: $new_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up tmux configuration? (Y/n): " config_choice
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
    
    # Ask to remove Tmux
    read -p "Are you sure you want to remove Tmux? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove Tmux based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y tmux
                ;;
            redhat)
                sudo dnf remove -y tmux
                ;;
            arch)
                sudo pacman -Rs --noconfirm tmux
                ;;
            suse)
                sudo zypper remove -y tmux
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall Tmux manually."
                ;;
        esac
        
        # Ask to remove configuration files
        read -p "Do you want to remove tmux configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            # Remove .tmux.conf
            if [ -f "$HOME/.tmux.conf" ]; then
                echo "Backing up .tmux.conf before removal..."
                cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"
                rm "$HOME/.tmux.conf"
                echo "Removed .tmux.conf"
            fi
            
            # Remove TPM and plugins
            if [ -d "$HOME/.tmux" ]; then
                rm -rf "$HOME/.tmux"
                echo "Removed tmux plugins directory"
            fi
            
            # Remove config directory
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                rm -rf "$PACKAGE_DOTFILES_DIR"
                echo "Removed tmux configuration directory"
            fi
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