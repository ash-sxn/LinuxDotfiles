#!/bin/bash

# Google Chrome installation script

# Package information
PACKAGE_NAME="Google Chrome"
PACKAGE_DESCRIPTION="Fast, secure, and free web browser built for the modern web"
PACKAGE_DOTFILES_DIR="$HOME/.config/google-chrome"

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

# Check if Chrome is already installed
is_installed() {
    if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
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

# Install Chrome on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    # Install dependencies
    sudo apt update
    sudo apt install -y wget gnupg2 apt-transport-https ca-certificates
    
    # Download and install Chrome based on architecture
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Add Google's repository key
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        
        # Add Chrome repository
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
        
        # Update package index
        sudo apt update
        
        # Install Chrome
        sudo apt install -y google-chrome-stable
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome official package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            sudo apt install -y chromium-browser || sudo apt install -y chromium
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    fi
    
    return $?
}

# Install Chrome on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "unsupported" ]; then
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Create repo file
        cat << EOF | sudo tee /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
        
        # Install Chrome
        if [ "$DISTRO" = "fedora" ]; then
            sudo dnf install -y google-chrome-stable
        else
            sudo yum install -y google-chrome-stable
        fi
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome official package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf install -y chromium
            else
                sudo yum install -y chromium
            fi
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    fi
    
    return $?
}

# Install Chrome on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        if command -v yay &> /dev/null; then
            yay -S --noconfirm google-chrome
        elif command -v paru &> /dev/null; then
            paru -S --noconfirm google-chrome
        else
            # Download from AUR and build manually
            echo "No AUR helper found. Installing using manual AUR method..."
            
            # Make sure base-devel is installed
            sudo pacman -S --noconfirm --needed base-devel git
            
            # Create temporary directory
            TEMP_DIR=$(mktemp -d)
            cd "$TEMP_DIR" || exit
            
            # Clone AUR package
            git clone https://aur.archlinux.org/google-chrome.git
            cd google-chrome || exit
            
            # Build and install package
            makepkg -si --noconfirm
            
            # Clean up
            cd "$HOME" || exit
            rm -rf "$TEMP_DIR"
        fi
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome official package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            sudo pacman -S --noconfirm chromium
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    else
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    return $?
}

# Install Chrome on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    get_arch
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Add Google Chrome repository
        sudo zypper addrepo -f http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
        
        # Import Google's signing key
        sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
        
        # Install Chrome
        sudo zypper install -y google-chrome-stable
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome official package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            sudo zypper install -y chromium
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    else
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    return $?
}

# Install Chrome using the .deb package method (fallback for Debian-based systems)
install_using_deb() {
    echo "Installing Google Chrome using .deb package..."
    get_arch
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Download the latest Chrome .deb package
        wget -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        
        # Install the package
        if command -v gdebi &> /dev/null; then
            sudo gdebi -n /tmp/chrome.deb
        else
            sudo dpkg -i /tmp/chrome.deb
            sudo apt-get install -f -y
        fi
        
        # Clean up
        rm /tmp/chrome.deb
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome .deb package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            sudo apt install -y chromium-browser || sudo apt install -y chromium
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    else
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    return $?
}

# Install Chrome using the .rpm package method (fallback for Red Hat-based systems)
install_using_rpm() {
    echo "Installing Google Chrome using .rpm package..."
    get_arch
    
    if [ "$ARCH_TYPE" = "amd64" ]; then
        # Download the latest Chrome .rpm package
        wget -O /tmp/chrome.rpm "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
        
        # Install the package
        if [ "$DISTRO" = "fedora" ]; then
            sudo dnf install -y /tmp/chrome.rpm
        else
            sudo yum install -y /tmp/chrome.rpm
        fi
        
        # Clean up
        rm /tmp/chrome.rpm
    elif [ "$ARCH_TYPE" = "arm64" ]; then
        echo "Google Chrome .rpm package is not available for ARM64 architecture."
        echo "Would you like to install Chromium browser instead? (Y/n): "
        read -r install_chromium
        
        if [[ ! "$install_chromium" =~ ^[Nn]$ ]]; then
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf install -y chromium
            else
                sudo yum install -y chromium
            fi
            echo "Chromium has been installed as an alternative to Google Chrome."
        else
            echo "Installation cancelled."
            return 1
        fi
    else
        echo "Error: Google Chrome is not available for your architecture."
        return 1
    fi
    
    return $?
}

# Configure Chrome
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Check if Chrome is installed
    if ! is_installed; then
        echo "Google Chrome is not installed. Cannot set up configuration."
        return 1
    fi
    
    # Ask user if they want privacy enhancements
    read -p "Would you like to set up Chrome with enhanced privacy settings? (y/N): " setup_privacy
    
    if [[ "$setup_privacy" =~ ^[Yy]$ ]]; then
        echo "Chrome must be launched at least once to create its configuration directory."
        echo "Launching Chrome in headless mode..."
        
        # Launch Chrome in headless mode and kill it after a few seconds to create config dir
        google-chrome --headless --disable-gpu https://www.google.com &
        CHROME_PID=$!
        sleep 3
        kill $CHROME_PID
        
        # Wait for Chrome to fully close
        sleep 2
        
        # Path to Preferences file
        PREFS_FILE="$HOME/.config/google-chrome/Default/Preferences"
        
        if [ -f "$PREFS_FILE" ]; then
            # Backup original preferences
            cp "$PREFS_FILE" "$PREFS_FILE.backup"
            
            # Update privacy settings using sed
            # Disable browser sign-in
            sed -i 's/"browser_signin_account_type":.*,/"browser_signin_account_type": 0,/g' "$PREFS_FILE"
            
            # Disable search suggestions
            sed -i 's/"search_suggest_enabled":.*,/"search_suggest_enabled": false,/g' "$PREFS_FILE"
            
            # Disable spell check service
            sed -i 's/"spellcheck.use_spelling_service":.*,/"spellcheck.use_spelling_service": false,/g' "$PREFS_FILE"
            
            # Disable safe browsing report
            sed -i 's/"safebrowsing.enabled":.*,/"safebrowsing.enabled": true,/g' "$PREFS_FILE"
            sed -i 's/"safebrowsing.disable_download_protection":.*,/"safebrowsing.disable_download_protection": false,/g' "$PREFS_FILE"
            
            # Disable network predictions
            sed -i 's/"network_prediction_options":.*,/"network_prediction_options": 2,/g' "$PREFS_FILE"
            
            # Disable navigation error suggestions
            sed -i 's/"alternate_error_pages.enabled":.*,/"alternate_error_pages.enabled": false,/g' "$PREFS_FILE"
            
            # Disable autofill
            sed -i 's/"autofill.enabled":.*,/"autofill.enabled": false,/g' "$PREFS_FILE"
            
            # Disable payment methods
            sed -i 's/"payments.can_make_payment_enabled":.*,/"payments.can_make_payment_enabled": false,/g' "$PREFS_FILE"
            
            echo "Privacy settings have been applied to Chrome preferences."
            echo "Note: These changes might be overwritten by Chrome on next launch if it detects inconsistencies."
            echo "You may need to adjust some settings manually in Chrome settings."
        else
            echo "Could not find Chrome preferences file at $PREFS_FILE"
            echo "Please launch Chrome manually once and then run this script again."
        fi
    else
        echo "Skipping privacy settings configuration."
    fi
    
    # Ask about installing extensions
    read -p "Would you like to install recommended Chrome extensions? (y/N): " install_extensions
    
    if [[ "$install_extensions" =~ ^[Yy]$ ]]; then
        echo "Please choose which extensions to install:"
        echo "1) uBlock Origin (ad blocker)"
        echo "2) Privacy Badger (tracker blocker)"
        echo "3) HTTPS Everywhere (force HTTPS)"
        echo "4) Bitwarden (password manager)"
        echo "5) Dark Reader (dark mode for websites)"
        echo "6) All of the above"
        echo "7) None"
        
        read -p "Enter your choice [1-7]: " extension_choice
        
        echo "Chrome will now open with extension installation pages."
        echo "You'll need to complete the installation manually for each extension."
        echo "Press Enter to continue..."
        read
        
        case $extension_choice in
            1)
                google-chrome https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm &
                ;;
            2)
                google-chrome https://chrome.google.com/webstore/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp &
                ;;
            3)
                google-chrome https://chrome.google.com/webstore/detail/https-everywhere/gcbommkclmclpchllfjekcdonpmejbdp &
                ;;
            4)
                google-chrome https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb &
                ;;
            5)
                google-chrome https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh &
                ;;
            6)
                google-chrome \
                    https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm \
                    https://chrome.google.com/webstore/detail/privacy-badger/pkehgijcmpdhfbdbbnkijodmdjhbjlgp \
                    https://chrome.google.com/webstore/detail/https-everywhere/gcbommkclmclpchllfjekcdonpmejbdp \
                    https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb \
                    https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh &
                ;;
            7)
                echo "No extensions selected."
                ;;
            *)
                echo "Invalid choice. Skipping extension installation."
                ;;
        esac
    else
        echo "Skipping extension installation."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        chrome_version=$(google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null)
        echo "$PACKAGE_NAME is already installed: $chrome_version"
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
            if ! install_debian; then
                echo "Repository installation failed, trying .deb package method..."
                install_using_deb
            fi
            ;;
        redhat)
            if ! install_redhat; then
                echo "Repository installation failed, trying .rpm package method..."
                install_using_rpm
            fi
            ;;
        arch)
            install_arch
            ;;
        suse)
            install_suse
            ;;
        *)
            echo "Unsupported distribution for direct installation."
            echo "Please check if Google Chrome is available for your distribution."
            return 1
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        chrome_version=$(google-chrome --version 2>/dev/null || google-chrome-stable --version 2>/dev/null)
        echo "Version: $chrome_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up Chrome configuration? (Y/n): " config_choice
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
    
    read -p "Are you sure you want to remove Google Chrome? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove package based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt purge -y google-chrome-stable
                sudo apt autoremove -y
                sudo rm -f /etc/apt/sources.list.d/google-chrome.list
                sudo rm -f /etc/apt/trusted.gpg.d/google-chrome.gpg
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y google-chrome-stable
                else
                    sudo yum remove -y google-chrome-stable
                fi
                sudo rm -f /etc/yum.repos.d/google-chrome.repo
                ;;
            arch)
                if command -v yay &> /dev/null; then
                    yay -Rns --noconfirm google-chrome
                elif command -v paru &> /dev/null; then
                    paru -Rns --noconfirm google-chrome
                else
                    sudo pacman -Rns --noconfirm google-chrome
                fi
                ;;
            suse)
                sudo zypper remove -y google-chrome-stable
                sudo zypper removerepo google-chrome
                ;;
            *)
                echo "Manual uninstallation required for your distribution."
                ;;
        esac
        
        # Ask about removing Chrome profile data
        read -p "Do you want to remove Chrome profile data (bookmarks, history, settings)? (y/N): " remove_data
        if [[ $remove_data =~ ^[Yy]$ ]]; then
            # Backup profiles before removal
            if [ -d "$HOME/.config/google-chrome" ]; then
                echo "Backing up Chrome profiles..."
                backup_dir="$HOME/.config/google-chrome-backup-$(date +%Y%m%d-%H%M%S)"
                mv "$HOME/.config/google-chrome" "$backup_dir"
                echo "Chrome profiles backed up to $backup_dir"
            fi
            
            # Remove Chrome cache
            rm -rf "$HOME/.cache/google-chrome"
            
            echo "Chrome profile data has been removed."
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