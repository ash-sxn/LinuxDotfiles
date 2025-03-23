#!/bin/bash

# VLC installation script

# Package information
PACKAGE_NAME="VLC"
PACKAGE_DESCRIPTION="Free and open-source cross-platform multimedia player"
PACKAGE_DOTFILES_DIR="$HOME/.config/vlc"

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

# Check if VLC is already installed
is_installed() {
    if command -v vlc &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install VLC on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Update package index
    sudo apt update
    
    # Install VLC and useful plugins
    sudo apt install -y vlc vlc-plugin-access-extra vlc-plugin-base vlc-plugin-video-output vlc-plugin-video-splitter vlc-plugin-video-filters vlc-plugin-qt vlc-l10n
    
    # Install additional multimedia codecs
    sudo apt install -y libavcodec-extra ffmpeg 2>/dev/null || true
    
    return $?
}

# Install VLC on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    if [ "$DISTRO" = "fedora" ]; then
        # Enable RPM Fusion repositories if not already enabled
        if ! rpm -q rpmfusion-free-release &>/dev/null; then
            sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        fi
        
        if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
            sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        fi
        
        # Install VLC and multimedia codecs
        sudo dnf install -y vlc ffmpeg
    else
        # For RHEL, CentOS, Rocky, etc.
        # Enable EPEL and RPM Fusion repositories
        sudo yum install -y epel-release
        
        if ! rpm -q rpmfusion-free-release &>/dev/null; then
            sudo yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm
        fi
        
        if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
            sudo yum install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
        fi
        
        # Install VLC and dependencies
        sudo yum install -y vlc ffmpeg
    fi
    
    return $?
}

# Install VLC on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install VLC and multimedia codecs
    sudo pacman -S --noconfirm vlc ffmpeg
    
    return $?
}

# Install VLC on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Add Packman repository if not already added
    if ! zypper lr | grep -q "Packman"; then
        sudo zypper ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_$(lsb_release -rs)/ packman
        sudo zypper --gpg-auto-import-keys refresh
    fi
    
    # Install VLC and multimedia codecs
    sudo zypper install -y --allow-vendor-change vlc vlc-codecs ffmpeg
    
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
        echo "Please install VLC manually following the instructions at: https://www.videolan.org/vlc/#download"
        return 1
    fi
    
    return $?
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create or modify VLC preferences
    read -p "Do you want to apply recommended VLC settings? (Y/n): " apply_settings
    if [[ ! $apply_settings =~ ^[Nn]$ ]]; then
        # We'll create a custom VLC configuration file
        # First, ensure the config directory exists
        mkdir -p "$HOME/.config/vlc"
        
        # Create vlcrc with some optimized settings if it doesn't exist
        # If it exists, we'll leave it as is to preserve user customizations
        if [ ! -f "$HOME/.config/vlc/vlcrc" ]; then
            echo "Creating optimized VLC configuration..."
            
            # Run VLC once with --reset-config to generate a clean config file if it doesn't exist
            if [ ! -d "$HOME/.config/vlc" ]; then
                vlc --reset-config --play-and-exit >/dev/null 2>&1 &
                VLC_PID=$!
                sleep 2
                kill $VLC_PID 2>/dev/null || true
                sleep 1
            fi
            
            # Now modify some key settings if the config file exists
            if [ -f "$HOME/.config/vlc/vlcrc" ]; then
                # Backup original config
                cp "$HOME/.config/vlc/vlcrc" "$HOME/.config/vlc/vlcrc.backup"
                
                # Apply optimized settings by substituting lines
                sed -i 's/#hardware-decoding=0/hardware-decoding=1/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#sub-auto-detect-fuzzy=1/sub-auto-detect-fuzzy=1/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#key-next=./key-next=n/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#key-prev=./key-prev=p/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#extraintf=.*/extraintf=none/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#snapshot-format=.*/snapshot-format=png/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#key-vol-up=.*/key-vol-up=Up/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#key-vol-down=.*/key-vol-down=Down/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#sub-language=.*/sub-language=eng/g' "$HOME/.config/vlc/vlcrc"
                sed -i 's/#auto-preparse=.*/auto-preparse=1/g' "$HOME/.config/vlc/vlcrc"
                
                echo "Applied optimized VLC settings."
            else
                echo "Warning: Could not find VLC configuration file."
            fi
        else
            echo "Existing VLC configuration found. Preserving user settings."
        fi
        
        # Create a default shortcuts file if it doesn't exist
        if [ ! -f "$HOME/.config/vlc/vlc-qt-interface.conf" ]; then
            echo "Setting up VLC keyboard shortcuts and interface preferences..."
            
            cat > "$HOME/.config/vlc/vlc-qt-interface.conf" << EOF
[General]
filedialog-path=@Variant(\0\0\0\x11\0\0\0\x15$HOME/Downloads)
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x5U\0\0\x2\xff\0\0\0\0\0\0\0\x14\0\0\x5U\0\0\x2\xff\0\0\0\0\0\0\0\0\x5V\0\0\0\0\0\0\0\x14\0\0\x5U\0\0\x2\xff)

[FullScreen]
pos=@Point(0 0)
screen=@Rect(0 0 0 0)
wide=false

[MainWindow]
AdvToolbar="12;11;13;14;"
FSCtoolbar="0-2;64;3;1;4;64;37;64;38;64;8;65;25;35-4;34;"
InputToolbar="43;33-4;44;"
MainToolbar1="64;39;64;38;65;"
MainToolbar2="0-2;64;3;1;4;64;7;9;64;10;20;19;64-4;37;65;35-4;"
ToolbarPos=false
adv-controls=0
bgSize=@Size(100 30)
pl-dock-status=true
playlist-visible=false
playlistSize=@Size(600 300)
status-bar-visible=false

[Preferences]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x1\xaa\0\0\0\x61\0\0\x3\xae\0\0\x2\xe3\0\0\x1\xaa\0\0\0}\0\0\x3\xae\0\0\x2\xe3\0\0\0\0\0\0\0\0\x5V\0\0\x1\xaa\0\0\0}\0\0\x3\xae\0\0\x2\xe3)

[RecentsMRL]
list=
times=

[playlistdialog]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x1\x8f\0\0\0\b\0\0\x3\xd0\0\0\x2\xd3\0\0\x1\x8f\0\0\0\b\0\0\x3\xd0\0\0\x2\xd3\0\0\0\0\0\0\0\0\x5V\0\0\x1\x8f\0\0\0\b\0\0\x3\xd0\0\0\x2\xd3)
EOF
            echo "Set up VLC interface preferences."
        else
            echo "Existing VLC interface configuration found. Preserving user settings."
        fi
    else
        echo "Skipping VLC settings configuration."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        vlc_version=$(vlc --version | head -n 1)
        echo "$PACKAGE_NAME is already installed: $vlc_version"
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
        vlc_version=$(vlc --version | head -n 1)
        echo "Version: $vlc_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up VLC configuration? (Y/n): " config_choice
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
    
    read -p "Are you sure you want to remove VLC? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove VLC based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y vlc vlc-*
                sudo apt autoremove -y
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y vlc
                else
                    sudo yum remove -y vlc
                fi
                ;;
            arch)
                sudo pacman -Rs --noconfirm vlc
                ;;
            suse)
                sudo zypper remove -y vlc
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall VLC manually using your distribution's package manager."
                ;;
        esac
        
        # Ask to remove configuration files
        read -p "Do you want to remove VLC configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            # Backup .config/vlc before removal
            if [ -d "$HOME/.config/vlc" ]; then
                echo "Backing up VLC configuration before removal..."
                backup_dir="$HOME/.config/vlc.backup.$(date +%Y%m%d-%H%M%S)"
                cp -r "$HOME/.config/vlc" "$backup_dir"
                echo "Configuration backed up to $backup_dir"
                
                # Remove config directory
                rm -rf "$HOME/.config/vlc"
                echo "Removed VLC configuration directory"
            fi
            
            # Remove VLC cache
            if [ -d "$HOME/.cache/vlc" ]; then
                rm -rf "$HOME/.cache/vlc"
                echo "Removed VLC cache directory"
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