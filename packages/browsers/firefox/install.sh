#!/bin/bash

# Firefox installation script

# Package information
PACKAGE_NAME="Firefox"
PACKAGE_DESCRIPTION="Free and open-source web browser developed by Mozilla"
PACKAGE_DOTFILES_DIR="$HOME/.mozilla/firefox"

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

# Check if Firefox is already installed
is_installed() {
    if command -v firefox &> /dev/null; then
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
            ARCH_TYPE="x86_64"
            ;;
        aarch64|arm64)
            ARCH_TYPE="aarch64"
            ;;
        *)
            ARCH_TYPE="unsupported"
            ;;
    esac
    
    echo "System architecture: $ARCH_TYPE"
}

# Install Firefox on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Update package index
    sudo apt update
    
    # Install Firefox
    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "pop" ]; then
        # Ubuntu 22.04+ and Pop!_OS use the snap package by default
        # Check if we're using a version that has switched to snap
        FIREFOX_PKG=$(apt-cache policy firefox | grep -c "firefox/jammy")
        
        if [ "$FIREFOX_PKG" -gt 0 ]; then
            echo "This Ubuntu version uses Firefox as a snap package by default."
            read -p "Would you like to install the .deb package instead of the snap? (y/N): " use_deb
            
            if [[ "$use_deb" =~ ^[Yy]$ ]]; then
                # Add Mozilla Team PPA for .deb version
                sudo add-apt-repository -y ppa:mozillateam/ppa
                
                # Create preferences file to prioritize deb over snap
                echo 'Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null
                
                # Make sure packages from PPA are preferred
                echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox > /dev/null
                
                # Update and install
                sudo apt update
                sudo apt install -y firefox
            else
                # Install the snap version
                sudo snap install firefox
            fi
        else
            # Normal apt install for distributions that still use .deb
            sudo apt install -y firefox
        fi
    else
        # For other Debian-based distributions
        sudo apt install -y firefox-esr || sudo apt install -y firefox
    fi
    
    return $?
}

# Install Firefox on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    if [ "$DISTRO" = "fedora" ]; then
        # Fedora already includes Firefox in its repositories
        sudo dnf install -y firefox
    else
        # For RHEL/CentOS/Rocky/Alma
        # Enable EPEL repository if not already enabled
        if ! rpm -q epel-release &>/dev/null; then
            sudo yum install -y epel-release
        fi
        
        # Install Firefox
        sudo yum install -y firefox
    fi
    
    return $?
}

# Install Firefox on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    if command -v yay &> /dev/null; then
        yay -S --noconfirm firefox
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm firefox
    else
        sudo pacman -S --noconfirm firefox
    fi
    
    return $?
}

# Install Firefox on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Install Firefox
    sudo zypper install -y MozillaFirefox
    
    return $?
}

# Install Firefox using the tarball method (fallback)
install_generic() {
    echo "Installing $PACKAGE_NAME using generic method..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Unsupported architecture: $ARCH"
        echo "Cannot install Firefox using the generic method."
        return 1
    fi
    
    # Create directory in /opt for Firefox
    sudo mkdir -p /opt/firefox
    
    # Download Firefox
    DOWNLOAD_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
    
    if [ "$ARCH_TYPE" = "aarch64" ]; then
        echo "ARM64 architecture detected. Note that official Firefox binaries for ARM are limited."
        echo "Attempting to download Firefox for ARM64, but this might not be available."
        DOWNLOAD_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux-aarch64&lang=en-US"
    fi
    
    echo "Downloading Firefox from $DOWNLOAD_URL"
    curl -L "$DOWNLOAD_URL" -o /tmp/firefox.tar.bz2
    
    # Extract to /opt
    sudo tar xjf /tmp/firefox.tar.bz2 -C /opt
    
    # Create symlink
    sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox
    
    # Create desktop entry
    cat << EOF | sudo tee /usr/share/applications/firefox.desktop
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF
    
    # Clean up
    rm /tmp/firefox.tar.bz2
    
    echo "Firefox has been installed to /opt/firefox"
    echo "You can run it by typing 'firefox' in the terminal or by using the application menu."
    
    return 0
}

# Setup custom preferences
setup_custom_preferences() {
    echo "Setting up custom Firefox preferences..."
    
    # Ask user if they want to set up custom preferences
    read -p "Do you want to set up enhanced privacy settings for Firefox? (y/N): " setup_privacy
    
    if [[ "$setup_privacy" =~ ^[Yy]$ ]]; then
        # Find profiles directory
        PROFILES_DIR="$HOME/.mozilla/firefox"
        
        if [ ! -d "$PROFILES_DIR" ]; then
            echo "Firefox profiles directory not found. Launch Firefox at least once to create it."
            firefox --headless &
            sleep 3
            killall firefox 2>/dev/null || killall firefox-bin 2>/dev/null
            sleep 1
        fi
        
        # Find default profile
        if [ -d "$PROFILES_DIR" ]; then
            PROFILE_PATH=$(grep "Path=" "$PROFILES_DIR/profiles.ini" | head -n 1 | cut -d'=' -f2)
            
            if [ -n "$PROFILE_PATH" ]; then
                PREFS_FILE="$PROFILES_DIR/$PROFILE_PATH/user.js"
                
                echo "// Custom privacy settings" > "$PREFS_FILE"
                
                # Enhanced privacy settings
                cat << EOF >> "$PREFS_FILE"
// Disable telemetry
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);

// Disable studies
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

// Disable crash reports
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);

// Enhanced tracking protection
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);

// HTTPS-Only mode
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_ever_enabled", true);

// DNS over HTTPS
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");

// Disable pocket
user_pref("extensions.pocket.enabled", false);
EOF
                
                echo "Privacy settings have been added to $PREFS_FILE"
                echo "These settings will be applied the next time you start Firefox."
            else
                echo "Could not find Firefox profile. Launch Firefox at least once to create it."
            fi
        else
            echo "Firefox profile directory not found."
        fi
    else
        echo "Skipping custom privacy settings."
    fi
}

# Setup additional add-ons
setup_addons() {
    echo "Setting up additional Firefox add-ons..."
    
    read -p "Do you want to install recommended Firefox add-ons? (y/N): " install_addons
    
    if [[ "$install_addons" =~ ^[Yy]$ ]]; then
        echo "Please choose which add-ons to install:"
        echo "1) uBlock Origin (ad blocker)"
        echo "2) Privacy Badger (tracker blocker)"
        echo "3) HTTPS Everywhere (force HTTPS)"
        echo "4) Bitwarden (password manager)"
        echo "5) Dark Reader (dark mode for websites)"
        echo "6) All of the above"
        echo "7) None"
        
        read -p "Enter your choice [1-7]: " addon_choice
        
        echo "To install the selected add-ons, Firefox will open with the appropriate add-on pages."
        echo "You'll need to complete the installation manually by clicking 'Add to Firefox' on each page."
        echo "Press Enter to continue..."
        read
        
        case $addon_choice in
            1)
                firefox https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/ &
                ;;
            2)
                firefox https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/ &
                ;;
            3)
                firefox https://addons.mozilla.org/en-US/firefox/addon/https-everywhere/ &
                ;;
            4)
                firefox https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/ &
                ;;
            5)
                firefox https://addons.mozilla.org/en-US/firefox/addon/darkreader/ &
                ;;
            6)
                firefox https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/ \
                       https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/ \
                       https://addons.mozilla.org/en-US/firefox/addon/https-everywhere/ \
                       https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/ \
                       https://addons.mozilla.org/en-US/firefox/addon/darkreader/ &
                ;;
            7)
                echo "No add-ons selected."
                ;;
            *)
                echo "Invalid choice. Skipping add-on installation."
                ;;
        esac
    else
        echo "Skipping add-on installation."
    fi
}

# Setup configuration
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Setup custom preferences
    setup_custom_preferences
    
    # Setup add-ons
    setup_addons
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        firefox_version=$(firefox --version 2>/dev/null || firefox-esr --version 2>/dev/null)
        echo "$PACKAGE_NAME is already installed: $firefox_version"
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
            echo "Unsupported distribution for direct installation."
            echo "Attempting generic installation method..."
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        firefox_version=$(firefox --version 2>/dev/null || firefox-esr --version 2>/dev/null)
        echo "Version: $firefox_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up Firefox configuration? (Y/n): " config_choice
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
    
    read -p "Are you sure you want to remove Firefox? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Determine if Firefox is installed via snap
        if command -v snap &> /dev/null && snap list | grep -q "firefox"; then
            echo "Removing Firefox snap package..."
            sudo snap remove firefox
        else
            # Remove package based on distribution family
            case $DISTRO_FAMILY in
                debian)
                    if [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "pop" ]; then
                        # Try to remove both .deb and snap versions
                        sudo apt purge -y firefox || true
                        snap remove firefox || true
                    else
                        sudo apt purge -y firefox firefox-esr
                    fi
                    sudo apt autoremove -y
                    ;;
                redhat)
                    if [ "$DISTRO" = "fedora" ]; then
                        sudo dnf remove -y firefox
                    else
                        sudo yum remove -y firefox
                    fi
                    ;;
                arch)
                    if command -v yay &> /dev/null; then
                        yay -Rns --noconfirm firefox
                    elif command -v paru &> /dev/null; then
                        paru -Rns --noconfirm firefox
                    else
                        sudo pacman -Rns --noconfirm firefox
                    fi
                    ;;
                suse)
                    sudo zypper remove -y MozillaFirefox
                    ;;
                *)
                    # Handle manual installation
                    sudo rm -f /usr/local/bin/firefox
                    sudo rm -f /usr/share/applications/firefox.desktop
                    sudo rm -rf /opt/firefox
                    ;;
            esac
        fi
        
        # Ask about removing Firefox profile data
        read -p "Do you want to remove Firefox profile data (bookmarks, history, settings)? (y/N): " remove_data
        if [[ $remove_data =~ ^[Yy]$ ]]; then
            # Backup profiles before removal
            if [ -d "$HOME/.mozilla/firefox" ]; then
                echo "Backing up Firefox profiles..."
                backup_dir="$HOME/.mozilla/firefox-backup-$(date +%Y%m%d-%H%M%S)"
                mv "$HOME/.mozilla/firefox" "$backup_dir"
                echo "Firefox profiles backed up to $backup_dir"
                
                # Remove Firefox profiles
                rm -rf "$HOME/.mozilla/firefox"
            fi
            
            # Remove any other Firefox data
            rm -rf "$HOME/.cache/mozilla/firefox"
            
            echo "Firefox profile data has been removed."
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