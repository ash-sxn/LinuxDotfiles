#!/bin/bash

# Complete GNOME Setup Script - Installation and Customization
# This script will install the latest GNOME Desktop Environment and then customize it

# Package information
PACKAGE_NAME="GNOME Desktop Environment"
PACKAGE_DESCRIPTION="Modern desktop environment with a focus on simplicity and user experience"

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print section header
print_section() {
    echo -e "\n${BLUE}===================================${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}===================================${NC}\n"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print warning/info message
print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

# Detect the Linux distribution
detect_distro() {
    print_section "Detecting Linux Distribution"
    
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
    
    print_success "Detected distribution: $DISTRO (Family: $DISTRO_FAMILY, Version: $VERSION_ID)"
}

# Check if GNOME is already installed
is_gnome_installed() {
    if [ -d "/usr/share/gnome" ] || [ -d "/usr/share/gnome-shell" ] || command -v gnome-shell &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install GNOME on Debian-based systems
install_debian() {
    print_section "Installing $PACKAGE_NAME on Debian-based system"
    
    # Update package index
    sudo apt update
    
    if [ "$DISTRO" = "ubuntu" ]; then
        # For Ubuntu, add the GNOME Team PPA to get the latest version
        print_warning "Adding GNOME Team PPA for latest GNOME version..."
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
    print_section "Installing $PACKAGE_NAME on Red Hat-based system"
    
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
    print_section "Installing $PACKAGE_NAME on Arch-based system"
    
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
    print_section "Installing $PACKAGE_NAME on SUSE-based system"
    
    # Install GNOME Desktop Environment
    sudo zypper install -y -t pattern gnome gnome_basis gnome_admin gnome_games gnome_imaging gnome_utilities
    sudo zypper install -y gnome-shell-extensions gnome-tweaks
    
    # Install theming tools and dependencies
    sudo zypper install -y sassc glib2-devel git meson
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    print_section "Installing $PACKAGE_NAME on unsupported distribution"
    print_warning "Attempting generic installation method..."
    
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
        print_error "Could not determine a suitable package manager."
        print_warning "Please install GNOME manually following your distribution's documentation."
        return 1
    fi
    
    return $?
}

# Install extension manager and necessary tools for customization
install_extension_tools() {
    print_section "Installing Extension Manager and customization tools"
    
    case $DISTRO_FAMILY in
        debian)
            sudo apt install -y chrome-gnome-shell || true
            sudo apt install -y gnome-shell-extension-manager || true
            ;;
        redhat)
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf install -y chrome-gnome-shell || true
                sudo dnf install -y gnome-shell-extension-manager || true
            else
                sudo yum install -y chrome-gnome-shell || true
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm gnome-browser-connector || true
            sudo pacman -S --noconfirm gnome-shell-extension-manager || true
            ;;
        suse)
            sudo zypper install -y chrome-gnome-shell || true
            ;;
        *)
            print_warning "Extension manager might not be available for your distribution."
            print_warning "You can install extensions from https://extensions.gnome.org/ manually."
            ;;
    esac
    
    # Install Flatpak and Flathub repository for additional apps
    if ! command -v flatpak &> /dev/null; then
        print_warning "Installing Flatpak..."
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
    
    print_warning "Installing theme-related Flatpak applications..."
    sudo flatpak install -y flathub com.mattjakeman.ExtensionManager || true
    sudo flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark || true
    
    return 0
}

# Install themes and customization
install_themes_and_customization() {
    print_section "Installing themes and customization packages"
    
    # Install theme dependencies based on distribution
    case $DISTRO_FAMILY in
        debian)
            sudo apt install -y sassc libglib2.0-dev git meson conky-all fonts-inter fonts-jetbrains-mono
            ;;
        redhat)
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf install -y sassc glib2-devel git meson conky inter-fonts jetbrains-mono-fonts
            else
                sudo yum install -y sassc glib2-devel git meson conky || true
            fi
            ;;
        arch)
            sudo pacman -S --noconfirm sassc glib2 git meson base-devel conky inter-font ttf-jetbrains-mono
            ;;
        suse)
            sudo zypper install -y sassc glib2-devel git meson conky || true
            ;;
        *)
            print_warning "Installing theme dependencies may not work for your distribution."
            print_warning "Please install them manually."
            ;;
    esac
    
    # Create a temporary directory for themes
    THEMES_DIR=$(mktemp -d)
    cd "$THEMES_DIR"
    
    # Install WhiteSur theme
    print_warning "Installing WhiteSur GTK theme..."
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
    cd WhiteSur-gtk-theme
    ./install.sh -c dark -a blue -m -l
    cd ..
    
    # Install Tela Circle icons
    print_warning "Installing Tela Circle icon theme..."
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
    cd Tela-circle-icon-theme
    ./install.sh blue
    cd ..
    
    # Cleanup temporary directory
    cd
    rm -rf "$THEMES_DIR"
    
    print_success "Themes and icons installed successfully"
}

# Configure GNOME settings
configure_gnome_settings() {
    print_section "Configuring GNOME settings for a customized look"
    
    # Download a nice wallpaper
    mkdir -p ~/Pictures/Wallpapers
    print_warning "Downloading wallpaper..."
    wget -O ~/Pictures/Wallpapers/blue-abstract.jpg "https://images.unsplash.com/photo-1579546929518-9e396f3cc809"
    
    # Apply GNOME settings
    print_warning "Applying GNOME settings (themes, icons, fonts)..."
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark-blue"
    gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-dark-blue"
    gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-blue-dark"
    gsettings set org.gnome.desktop.interface font-name "Inter 10" || gsettings set org.gnome.desktop.interface font-name "Ubuntu 10"
    gsettings set org.gnome.desktop.interface document-font-name "Inter 11" || gsettings set org.gnome.desktop.interface document-font-name "Ubuntu 11"
    gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 10" || gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono 11"
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Inter Bold 11" || gsettings set org.gnome.desktop.wm.preferences titlebar-font "Ubuntu Bold 11"
    gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Pictures/Wallpapers/blue-abstract.jpg"
    gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$USER/Pictures/Wallpapers/blue-abstract.jpg"
    
    # Set additional UI/UX preferences
    print_warning "Setting additional UI preferences..."
    gsettings set org.gnome.desktop.interface enable-animations true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.calendar show-weekdate true
    gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
    gsettings set org.gnome.desktop.interface clock-show-seconds false
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    
    # Set color scheme to prefer dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    
    # Change mouse/touchpad settings
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    
    print_success "GNOME settings applied successfully"
}

# Set up Conky
setup_conky() {
    print_section "Setting up Conky system monitor"
    
    # Create Conky configuration directory
    mkdir -p ~/.config/conky
    
    # Create Conky config file
    cat > ~/.config/conky/conky.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'Inter:size=10',
    gap_x = 30,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
${color dodgerblue}${font Inter:size=40}${time %H:%M}${font}${color}
${color white}${font Inter:size=14}${time %A %d %B %Y}${font}${color}

${color dodgerblue}SYSTEM ${hr 2}${color}
${color white}Hostname: $nodename
Kernel: $kernel
Uptime: $uptime
${color dodgerblue}CPU ${hr 2}${color}
${color white}CPU: ${cpu cpu0}% ${cpubar cpu0}
${color dodgerblue}MEMORY ${hr 2}${color}
${color white}RAM: $mem/$memmax - $memperc% ${membar}
${color dodgerblue}DISK ${hr 2}${color}
${color white}Root: ${fs_used /}/${fs_size /} ${fs_bar /}
Home: ${fs_used /home}/${fs_size /home} ${fs_bar /home}
]]
EOF

    # Create autostart entry for Conky
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/conky.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky -d -c ~/.config/conky/conky.conf
Terminal=false
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

    print_success "Conky system monitor set up successfully"
}

# Install recommended GNOME extensions
install_recommended_extensions() {
    print_section "Setting up recommended GNOME extensions"
    
    # Check if we have the GNOME extensions CLI installed
    if command -v gnome-extensions &> /dev/null; then
        print_warning "Installing recommended extensions via CLI..."
        
        # List of extension UUIDs to install
        # Note: This might not work on all systems, as extensions sometimes need to be installed via the browser
        EXTENSIONS=(
            "dash-to-dock@micxgx.gmail.com"
            "blur-my-shell@aunetx"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "just-perfection-desktop@just-perfection"
            "gsconnect@andyholmes.github.io"
            "arcmenu@arcmenu.com"
            "Vitals@CoreCoding.com"
            "openweather-extension@jenslody.de"
        )
        
        for ext in "${EXTENSIONS[@]}"; do
            gnome-extensions install "$ext" || print_warning "Failed to install $ext"
        done
        
        print_warning "Enabling extensions..."
        for ext in "${EXTENSIONS[@]}"; do
            gnome-extensions enable "$ext" || print_warning "Failed to enable $ext"
        done
    else
        print_warning "GNOME extensions CLI not available. Extensions need to be installed manually."
        print_warning "Visit https://extensions.gnome.org/ in a browser with the GNOME Shell Integration plugin."
        print_warning "Recommended extensions:"
        print_warning "  - Dash to Dock"
        print_warning "  - Blur my Shell"
        print_warning "  - User Themes"
        print_warning "  - Just Perfection"
        print_warning "  - GSConnect"
        print_warning "  - ArcMenu"
        print_warning "  - Vitals"
        print_warning "  - OpenWeather"
    fi
    
    print_success "GNOME extensions setup completed"
}

# Main installation function for GNOME
install_gnome() {
    print_section "Installing $PACKAGE_NAME"
    
    if is_gnome_installed; then
        GNOME_VERSION=$(gnome-shell --version 2>/dev/null || echo "GNOME is installed (version cannot be determined)")
        print_warning "$PACKAGE_NAME is already installed: $GNOME_VERSION"
        read -p "Do you want to update/reinstall it? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            print_warning "Skipping GNOME installation, proceeding to customization."
            return 0
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
    
    if is_gnome_installed; then
        print_success "$PACKAGE_NAME has been successfully installed!"
        GNOME_VERSION=$(gnome-shell --version 2>/dev/null || echo "Version cannot be determined")
        print_success "Version: $GNOME_VERSION"
        return 0
    else
        print_error "Failed to install $PACKAGE_NAME."
        return 1
    fi
}

# Main function to run the entire setup
main() {
    # Display welcome message
    print_section "GNOME Desktop Installation and Customization"
    echo "This script will install the latest GNOME Desktop Environment and customize it to match a modern, sleek look."
    echo "The customization includes themes, icons, extensions, and configuration settings."
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    # Detect Linux distribution
    detect_distro
    
    # Install GNOME if not already installed
    install_gnome
    
    # Install extension tools and other utilities
    print_warning "Installing extension tools and utilities..."
    install_extension_tools
    
    # Install themes and customization
    print_warning "Setting up themes and customization..."
    read -p "Do you want to install custom themes and icons? (Y/n): " themes_choice
    if [[ ! $themes_choice =~ ^[Nn]$ ]]; then
        install_themes_and_customization
    fi
    
    # Configure GNOME settings
    print_warning "Configuring GNOME settings..."
    read -p "Do you want to apply custom GNOME settings? (Y/n): " settings_choice
    if [[ ! $settings_choice =~ ^[Nn]$ ]]; then
        configure_gnome_settings
    fi
    
    # Setup Conky
    read -p "Do you want to set up Conky system monitor? (Y/n): " conky_choice
    if [[ ! $conky_choice =~ ^[Nn]$ ]]; then
        setup_conky
    fi
    
    # Install recommended extensions
    read -p "Do you want to set up recommended GNOME extensions? (Y/n): " extensions_choice
    if [[ ! $extensions_choice =~ ^[Nn]$ ]]; then
        install_recommended_extensions
    fi
    
    # Final message
    print_section "Setup Complete!"
    print_success "GNOME has been installed and customized successfully."
    print_warning "To apply all changes, please log out and log back in with GNOME selected."
    print_warning "Some settings may require a full system reboot."
    
    # Ask if user wants to reboot
    read -p "Would you like to reboot now? (y/N): " reboot_choice
    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        print_warning "Rebooting system in 5 seconds..."
        sleep 5
        sudo reboot
    fi
}

# Execute main function
main 