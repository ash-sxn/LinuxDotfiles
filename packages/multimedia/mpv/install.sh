#!/bin/bash

# MPV installation script

# Package information
PACKAGE_NAME="MPV"
PACKAGE_DESCRIPTION="Free, open-source, and cross-platform media player"
PACKAGE_DOTFILES_DIR="$HOME/.config/mpv"

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

# Check if MPV is already installed
is_installed() {
    if command -v mpv &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install MPV on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Update package index
    sudo apt update
    
    # Install MPV and useful plugins/codecs
    sudo apt install -y mpv ffmpeg libavcodec-extra libass9 libvdpau1 libva-drm2 libva-x11-2 libva2
    
    # Install additional hardware acceleration libraries if available
    sudo apt install -y mesa-va-drivers mesa-vdpau-drivers va-driver-all vdpau-driver-all 2>/dev/null || true
    
    # Install youtube-dl for streaming support
    sudo apt install -y youtube-dl yt-dlp || sudo apt install -y python3-pip && sudo pip3 install youtube-dl yt-dlp
    
    return $?
}

# Install MPV on Red Hat-based systems
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
        
        # Install MPV and useful plugins/codecs
        sudo dnf install -y mpv ffmpeg youtube-dl yt-dlp libva libvdpau mesa-vdpau-drivers mesa-libEGL mesa-libGL
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
        
        # Install MPV and dependencies
        sudo yum install -y mpv ffmpeg youtube-dl yt-dlp libva libvdpau mesa-vdpau-drivers mesa-libEGL mesa-libGL
    fi
    
    return $?
}

# Install MPV on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install MPV and useful plugins/codecs
    sudo pacman -S --noconfirm mpv ffmpeg libass libva libvdpau mesa youtube-dl yt-dlp
    
    return $?
}

# Install MPV on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Install MPV and dependencies
    sudo zypper install -y mpv ffmpeg libass9 libavcodec libva libvdpau youtube-dl
    
    # Install yt-dlp if available
    sudo zypper install -y yt-dlp || sudo pip3 install yt-dlp
    
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
        echo "Please install MPV manually following the instructions at: https://mpv.io/installation/"
        return 1
    fi
    
    return $?
}

# Setup basic configuration
setup_basic_config() {
    echo "Setting up basic MPV configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create a basic mpv.conf file
    cat > "$PACKAGE_DOTFILES_DIR/mpv.conf" << EOF
# MPV Configuration

# Video Settings
profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp
video-sync=display-resample
interpolation
tscale=oversample
hwdec=auto-safe

# Audio Settings
audio-channels=stereo
volume=100
volume-max=150

# OSD Settings
osd-level=1
osd-duration=2500
osd-font='Sans'
osd-font-size=32
osd-color='#FFFFFF'
osd-border-color='#000000'
osd-bar=yes
osd-bar-align-y=0
osd-border-size=1
osd-bar-h=2
osd-bar-w=60

# Subtitle Settings
sub-auto=fuzzy
sub-font='Sans'
sub-font-size=40
sub-color='#FFFFFF'
sub-border-color='#000000'
sub-border-size=2
sub-shadow-offset=1
sub-shadow-color='#000000'
sub-spacing=0.5

# Screenshot Settings
screenshot-format=png
screenshot-high-bit-depth=yes
screenshot-png-compression=7
screenshot-directory=~/Pictures/Screenshots

# Playback Settings
keep-open=yes
save-position-on-quit
EOF
    
    # Create input.conf for key bindings
    cat > "$PACKAGE_DOTFILES_DIR/input.conf" << EOF
# MPV Key Bindings

# Arrow keys for seeking
RIGHT seek 5
LEFT seek -5
UP seek 60
DOWN seek -60

# Page keys for bigger seeks
Shift+RIGHT seek 30
Shift+LEFT seek -30
Shift+UP seek 300
Shift+DOWN seek -300

# Volume control
+ add volume 5
- add volume -5
m cycle mute

# Playback speed
[ multiply speed 0.9091
] multiply speed 1.1
{ multiply speed 0.5
} multiply speed 2.0
BS set speed 1.0 # Backspace resets speed

# Subtitle control
z add sub-delay -0.1
x add sub-delay +0.1
v cycle sub-visibility

# Audio track selection
a cycle audio

# Subtitle track selection
s cycle sub

# Toggle fullscreen
f cycle fullscreen

# Take screenshots
S screenshot
s screenshot video

# Toggle OSD levels
o cycle-values osd-level 3 1
EOF
    
    echo "Basic MPV configuration has been set up at $PACKAGE_DOTFILES_DIR"
}

# Setup yt-dlp config for better YouTube playback
setup_ytdlp_config() {
    echo "Setting up yt-dlp configuration for better streaming..."
    
    # Create yt-dlp config directory
    mkdir -p "$HOME/.config/yt-dlp"
    
    # Create yt-dlp config file
    cat > "$HOME/.config/yt-dlp/config" << EOF
# yt-dlp configuration for better streaming

# General settings
--no-mtime
--no-overwrites

# Video and audio settings for streaming
--format bestvideo[height<=?1080][fps<=?60][vcodec!=?vp9]+bestaudio/best
--merge-output-format mkv

# MPV compatibility
--downloader-args ffmpeg:"ffmpeg_i:-nostats -loglevel 0"
EOF
    
    echo "yt-dlp configuration has been set up at $HOME/.config/yt-dlp/config"
}

# Setup script to update yt-dlp periodically
setup_ytdlp_updater() {
    echo "Setting up yt-dlp updater script..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Create update script
    cat > "$HOME/.local/bin/update-yt-dlp" << EOF
#!/bin/bash

# Script to update yt-dlp

echo "Updating yt-dlp..."

if command -v pip3 &> /dev/null; then
    pip3 install -U yt-dlp
elif command -v pip &> /dev/null; then
    pip install -U yt-dlp
else
    echo "Python pip not found. Please install Python and pip."
    exit 1
fi

echo "yt-dlp has been updated to the latest version."
EOF
    
    # Make script executable
    chmod +x "$HOME/.local/bin/update-yt-dlp"
    
    echo "yt-dlp updater script has been set up at $HOME/.local/bin/update-yt-dlp"
    echo "You can run it periodically to keep yt-dlp up to date."
}

# Setup configuration
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Ask if user wants to set up basic configuration
    read -p "Do you want to set up a basic MPV configuration? (Y/n): " setup_basic
    if [[ ! $setup_basic =~ ^[Nn]$ ]]; then
        setup_basic_config
    else
        echo "Skipping basic configuration setup."
    fi
    
    # Ask if user wants to set up yt-dlp config for better YouTube streaming
    read -p "Do you want to set up yt-dlp configuration for better video streaming? (Y/n): " setup_ytdlp
    if [[ ! $setup_ytdlp =~ ^[Nn]$ ]]; then
        setup_ytdlp_config
        setup_ytdlp_updater
    else
        echo "Skipping yt-dlp configuration setup."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        mpv_version=$(mpv --version | head -n 1)
        echo "$PACKAGE_NAME is already installed: $mpv_version"
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
        mpv_version=$(mpv --version | head -n 1)
        echo "Version: $mpv_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up MPV configuration? (Y/n): " config_choice
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
    
    read -p "Are you sure you want to remove MPV? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove MPV based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y mpv
                sudo apt autoremove -y
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y mpv
                else
                    sudo yum remove -y mpv
                fi
                ;;
            arch)
                sudo pacman -Rs --noconfirm mpv
                ;;
            suse)
                sudo zypper remove -y mpv
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall MPV manually using your distribution's package manager."
                ;;
        esac
        
        # Ask to remove configuration files
        read -p "Do you want to remove MPV configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            # Backup .config/mpv before removal
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                echo "Backing up MPV configuration before removal..."
                backup_dir="$PACKAGE_DOTFILES_DIR.backup.$(date +%Y%m%d-%H%M%S)"
                cp -r "$PACKAGE_DOTFILES_DIR" "$backup_dir"
                echo "Configuration backed up to $backup_dir"
                
                # Remove config directory
                rm -rf "$PACKAGE_DOTFILES_DIR"
                echo "Removed MPV configuration directory"
            fi
            
            # Remove yt-dlp configuration
            if [ -d "$HOME/.config/yt-dlp" ]; then
                rm -rf "$HOME/.config/yt-dlp"
                echo "Removed yt-dlp configuration directory"
            fi
            
            # Remove updater script
            if [ -f "$HOME/.local/bin/update-yt-dlp" ]; then
                rm -f "$HOME/.local/bin/update-yt-dlp"
                echo "Removed yt-dlp updater script"
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