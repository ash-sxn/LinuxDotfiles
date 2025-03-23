#!/bin/bash

# Visual Studio Code installation script

# Package information
PACKAGE_NAME="Visual Studio Code"
PACKAGE_DESCRIPTION="Code editing. Redefined."
PACKAGE_DOTFILES_DIR="$HOME/.config/Code"

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

# Check if VS Code is already installed
is_installed() {
    if command -v code &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install VS Code on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Install dependencies
    sudo apt update
    sudo apt install -y curl apt-transport-https wget gpg

    # Add Microsoft GPG key
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    rm microsoft.gpg
    
    # Add Microsoft VS Code repository
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    
    # Update apt and install VS Code
    sudo apt update
    sudo apt install -y code
    
    return $?
}

# Install VS Code on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Import Microsoft key
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    # Add Microsoft VS Code repository
    if [ "$DISTRO" = "fedora" ]; then
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        
        # Update and install VS Code
        sudo dnf check-update
        sudo dnf install -y code
    else
        # For RHEL/CentOS
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        
        # Update and install VS Code
        sudo yum check-update
        sudo yum install -y code
    fi
    
    return $?
}

# Install VS Code on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    if command -v yay &> /dev/null; then
        yay -S --noconfirm visual-studio-code-bin
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm visual-studio-code-bin
    else
        sudo pacman -S --noconfirm code
    fi
    
    return $?
}

# Install VS Code on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Import Microsoft key
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    # Add Microsoft VS Code repository
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
    
    # Refresh repositories and install VS Code
    sudo zypper refresh
    sudo zypper install -y code
    
    return $?
}

# Install VS Code using the .deb package (fallback method)
install_using_deb() {
    echo "Installing VS Code using .deb package..."
    
    # Download the latest VS Code .deb package
    wget -O /tmp/vscode_latest.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    
    # Install the package
    if command -v gdebi &> /dev/null; then
        sudo gdebi -n /tmp/vscode_latest.deb
    else
        sudo dpkg -i /tmp/vscode_latest.deb
        sudo apt-get install -f -y
    fi
    
    # Clean up
    rm /tmp/vscode_latest.deb
    
    return $?
}

# Install VS Code using the .rpm package (fallback method)
install_using_rpm() {
    echo "Installing VS Code using .rpm package..."
    
    # Download the latest VS Code .rpm package
    wget -O /tmp/vscode_latest.rpm "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
    
    # Install the package
    sudo rpm -i /tmp/vscode_latest.rpm
    
    # Clean up
    rm /tmp/vscode_latest.rpm
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method via tarball..."
    
    # Download VS Code tarball
    wget -O /tmp/vscode.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
    
    # Extract to local directory
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.local/share/applications
    mkdir -p $HOME/.local/share/icons
    
    tar -xzf /tmp/vscode.tar.gz -C /tmp
    cp -r /tmp/VSCode-linux-x64/* $HOME/.local/
    
    # Create a symlink for the executable
    ln -sf $HOME/.local/bin/code $HOME/.local/bin/code
    
    # Add to PATH if not already there
    if ! echo $PATH | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Create a desktop file
    cat > $HOME/.local/share/applications/code.desktop << EOL
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=$HOME/.local/bin/code --unity-launch %F
Icon=$HOME/.local/share/icons/vscode.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;
EOL

    # Cleanup
    rm -rf /tmp/VSCode-linux-x64
    rm /tmp/vscode.tar.gz
    
    echo "VS Code has been installed to $HOME/.local/"
    echo "You may need to log out and log back in for the application to appear in your menu."
    
    return 0
}

# Install extensions function
install_extensions() {
    echo "Installing recommended VS Code extensions..."
    
    # Define an array of recommended extensions
    EXTENSIONS=(
        # Programming languages support
        "ms-python.python"
        "ms-vscode.cpptools"
        "golang.go"
        "rust-lang.rust-analyzer"
        "redhat.java"
        "ms-dotnettools.csharp"
        "ms-vscode.powershell"
        "svelte.svelte-vscode"
        "dartcode.dart-code"
        "ms-vscode.node-debug2"
        
        # Web development
        "dbaeumer.vscode-eslint"
        "esbenp.prettier-vscode"
        "ritwickdey.liveserver"
        "ms-azuretools.vscode-docker"
        
        # Git integration
        "eamodio.gitlens"
        
        # AI assistance
        "github.copilot"
        
        # Themes
        "GitHub.github-vscode-theme"
        "dracula-theme.theme-dracula"
        "PKief.material-icon-theme"
        
        # Productivity
        "streetsidesoftware.code-spell-checker"
        "yzhang.markdown-all-in-one"
        "shardulm94.trailing-spaces"
        "ms-vsliveshare.vsliveshare"
        "vscodevim.vim"
    )
    
    # Ask which extensions the user wants to install
    echo "Which categories of extensions would you like to install?"
    echo "1. All recommended extensions"
    echo "2. Basic programming language support only"
    echo "3. Web development extensions"
    echo "4. None - I'll install my own extensions"
    read -p "Enter your choice [1-4]: " extension_choice
    
    case $extension_choice in
        1)
            echo "Installing all recommended extensions..."
            for ext in "${EXTENSIONS[@]}"; do
                code --install-extension "$ext" --force
            done
            ;;
        2)
            echo "Installing basic programming language support..."
            code --install-extension ms-python.python --force
            code --install-extension ms-vscode.cpptools --force
            code --install-extension golang.go --force
            code --install-extension rust-lang.rust-analyzer --force
            code --install-extension dbaeumer.vscode-eslint --force
            ;;
        3)
            echo "Installing web development extensions..."
            code --install-extension dbaeumer.vscode-eslint --force
            code --install-extension esbenp.prettier-vscode --force
            code --install-extension ritwickdey.liveserver --force
            code --install-extension ms-azuretools.vscode-docker --force
            ;;
        4)
            echo "Skipping extension installation."
            ;;
        *)
            echo "Invalid choice. Skipping extension installation."
            ;;
    esac
}

# Setup settings function
setup_settings() {
    # Define settings file path
    SETTINGS_FILE="$HOME/.config/Code/User/settings.json"
    
    # Create User directory if it doesn't exist
    mkdir -p "$HOME/.config/Code/User"
    
    # Check if settings file already exists
    if [ -f "$SETTINGS_FILE" ]; then
        echo "Settings file already exists."
        read -p "Do you want to backup and overwrite it? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            echo "Keeping existing settings file."
            return
        fi
        
        # Backup existing settings
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d-%H%M%S)"
        echo "Settings file backed up."
    fi
    
    # Create a basic settings.json file
    echo "Creating settings.json with sensible defaults..."
    cat > "$SETTINGS_FILE" << EOL
{
    "editor.fontFamily": "'Droid Sans Mono', 'monospace', monospace",
    "editor.fontSize": 14,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": false,
    "editor.renderWhitespace": "boundary",
    "editor.minimap.enabled": true,
    "editor.wordWrap": "off",
    "editor.linkedEditing": true,
    "editor.rulers": [80, 120],
    
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.insertFinalNewline": true,
    "files.trimTrailingWhitespace": true,
    
    "terminal.integrated.fontFamily": "monospace",
    "terminal.integrated.fontSize": 14,
    
    "telemetry.telemetryLevel": "off",
    
    "window.zoomLevel": 0,
    
    "workbench.startupEditor": "welcomePage",
    "workbench.iconTheme": "material-icon-theme",
    "workbench.colorTheme": "GitHub Dark",
    
    "[python]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "ms-python.python"
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[html]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[css]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
}
EOL
    
    echo "Basic settings.json file has been created."
}

# Setup keybindings function
setup_keybindings() {
    # Define keybindings file path
    KEYBINDINGS_FILE="$HOME/.config/Code/User/keybindings.json"
    
    # Create User directory if it doesn't exist
    mkdir -p "$HOME/.config/Code/User"
    
    # Check if keybindings file already exists
    if [ -f "$KEYBINDINGS_FILE" ]; then
        echo "Keybindings file already exists."
        read -p "Do you want to backup and overwrite it? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            echo "Keeping existing keybindings file."
            return
        fi
        
        # Backup existing keybindings
        cp "$KEYBINDINGS_FILE" "$KEYBINDINGS_FILE.backup.$(date +%Y%m%d-%H%M%S)"
        echo "Keybindings file backed up."
    fi
    
    # Create keybindings.json with some useful defaults
    echo "Creating keybindings.json with useful defaults..."
    cat > "$KEYBINDINGS_FILE" << EOL
[
    // Toggle terminal
    {
        "key": "ctrl+`",
        "command": "workbench.action.terminal.toggleTerminal"
    },
    // Toggle sidebar
    {
        "key": "ctrl+b",
        "command": "workbench.action.toggleSidebarVisibility"
    },
    // Navigate between editor groups
    {
        "key": "ctrl+k ctrl+left",
        "command": "workbench.action.focusLeftGroup"
    },
    {
        "key": "ctrl+k ctrl+right",
        "command": "workbench.action.focusRightGroup"
    },
    // Format document
    {
        "key": "ctrl+shift+i",
        "command": "editor.action.formatDocument"
    },
    // Comment line or selection
    {
        "key": "ctrl+/",
        "command": "editor.action.commentLine",
        "when": "editorTextFocus && !editorReadonly"
    }
]
EOL
    
    echo "Basic keybindings.json file has been created."
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Install extensions
    install_extensions
    
    # Setup VS Code settings
    read -p "Do you want to set up VS Code's settings.json with sensible defaults? (y/N): " settings_choice
    if [[ $settings_choice =~ ^[Yy]$ ]]; then
        setup_settings
    else
        echo "Skipping settings.json setup."
    fi
    
    # Setup VS Code keybindings
    read -p "Do you want to set up VS Code's keybindings.json with useful keybindings? (y/N): " keybindings_choice
    if [[ $keybindings_choice =~ ^[Yy]$ ]]; then
        setup_keybindings
    else
        echo "Skipping keybindings.json setup."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        current_version=$(code --version | head -n 1)
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
            if ! install_debian; then
                echo "Repository installation failed, trying .deb package..."
                install_using_deb
            fi
            ;;
        redhat)
            if ! install_redhat; then
                echo "Repository installation failed, trying .rpm package..."
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
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        new_version=$(code --version | head -n 1)
        echo "Version: $new_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up VS Code configuration? (Y/n): " config_choice
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
    
    # Ask to remove VS Code
    read -p "Are you sure you want to remove VS Code? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove VS Code based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y code
                sudo rm /etc/apt/sources.list.d/vscode.list
                sudo rm /etc/apt/trusted.gpg.d/microsoft.gpg
                ;;
            redhat)
                if [ "$DISTRO" = "fedora" ]; then
                    sudo dnf remove -y code
                else
                    sudo yum remove -y code
                fi
                sudo rm /etc/yum.repos.d/vscode.repo
                ;;
            arch)
                if command -v yay &> /dev/null; then
                    yay -R --noconfirm visual-studio-code-bin
                elif command -v paru &> /dev/null; then
                    paru -R --noconfirm visual-studio-code-bin
                else
                    sudo pacman -R --noconfirm code
                fi
                ;;
            suse)
                sudo zypper remove -y code
                sudo rm /etc/zypp/repos.d/vscode.repo
                ;;
            *)
                # For the generic installation
                rm -rf $HOME/.local/bin/code $HOME/.local/share/applications/code.desktop
                ;;
        esac
        
        # Ask to remove configuration files
        read -p "Do you want to remove VS Code configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            echo "Backing up configuration before removal..."
            backup_dir="$HOME/.config/Code-backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$backup_dir"
            
            if [ -d "$HOME/.config/Code" ]; then
                cp -r "$HOME/.config/Code" "$backup_dir"
                rm -rf "$HOME/.config/Code"
                echo "Removed VS Code configuration directory"
            fi
            
            if [ -d "$HOME/.vscode" ]; then
                cp -r "$HOME/.vscode" "$backup_dir"
                rm -rf "$HOME/.vscode"
                echo "Removed .vscode directory"
            fi
            
            echo "Configuration backed up to $backup_dir"
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