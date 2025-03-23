#!/bin/bash

# Git installation script

# Package information
PACKAGE_NAME="Git"
PACKAGE_DESCRIPTION="Distributed version control system"
PACKAGE_DOTFILES_DIR="$HOME/.config/git"

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

# Check if Git is already installed
is_installed() {
    if command -v git &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install Git on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    sudo apt update
    sudo apt install -y git git-lfs git-flow

    # Install additional Git tools
    sudo apt install -y tig gitg meld
    
    return $?
}

# Install Git on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    sudo dnf install -y git git-lfs git-flow-avh
    
    # Install additional Git tools
    sudo dnf install -y tig gitg meld
    
    return $?
}

# Install Git on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    sudo pacman -S --noconfirm git git-lfs git-flow
    
    # Install additional Git tools
    sudo pacman -S --noconfirm tig gitg meld
    
    return $?
}

# Install Git on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    sudo zypper install -y git git-lfs git-flow
    
    # Install additional Git tools
    sudo zypper install -y tig gitg meld
    
    return $?
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method..."
    
    echo "Git is available on most Linux distributions."
    echo "Please install Git using your distribution's package manager."
    
    return 1  # Return failure
}

# Setup global Git configuration
setup_git_config() {
    # Check if user.name and user.email are already set
    if ! git config --global user.name &> /dev/null || ! git config --global user.email &> /dev/null; then
        echo "Setting up Git user configuration..."
        
        # Ask for user name and email if not already set
        if ! git config --global user.name &> /dev/null; then
            read -p "Enter your name for Git commit messages: " git_name
            if [ -n "$git_name" ]; then
                git config --global user.name "$git_name"
                echo "Git user.name set to: $git_name"
            else
                echo "Skipping Git user.name setup."
            fi
        else
            current_name=$(git config --global user.name)
            echo "Git user.name is already set to: $current_name"
        fi
        
        if ! git config --global user.email &> /dev/null; then
            read -p "Enter your email for Git commit messages: " git_email
            if [ -n "$git_email" ]; then
                git config --global user.email "$git_email"
                echo "Git user.email set to: $git_email"
            else
                echo "Skipping Git user.email setup."
            fi
        else
            current_email=$(git config --global user.email)
            echo "Git user.email is already set to: $current_email"
        fi
    else
        current_name=$(git config --global user.name)
        current_email=$(git config --global user.email)
        echo "Git user information is already configured:"
        echo "Name: $current_name"
        echo "Email: $current_email"
    fi
    
    # Setup other common Git configurations
    echo "Setting up other Git configurations..."
    
    # Default branch name
    if ! git config --global init.defaultBranch &> /dev/null; then
        read -p "Enter default branch name for new repositories [main]: " default_branch
        default_branch=${default_branch:-main}
        git config --global init.defaultBranch "$default_branch"
        echo "Default branch name set to: $default_branch"
    else
        current_default_branch=$(git config --global init.defaultBranch)
        echo "Default branch name is already set to: $current_default_branch"
    fi
    
    # Editor
    if ! git config --global core.editor &> /dev/null; then
        if command -v nvim &> /dev/null; then
            default_editor="nvim"
        elif command -v vim &> /dev/null; then
            default_editor="vim"
        else
            default_editor="nano"
        fi
        
        read -p "Enter preferred Git editor [$default_editor]: " git_editor
        git_editor=${git_editor:-$default_editor}
        git config --global core.editor "$git_editor"
        echo "Git editor set to: $git_editor"
    else
        current_editor=$(git config --global core.editor)
        echo "Git editor is already set to: $current_editor"
    fi
    
    # Colorful output
    git config --global color.ui auto
    
    # Pull strategy
    git config --global pull.rebase false
    
    # Push strategy
    git config --global push.default simple
    
    # Diff and merge tool
    if command -v meld &> /dev/null; then
        git config --global diff.tool meld
        git config --global merge.tool meld
    fi
    
    # Aliases
    echo "Setting up useful Git aliases..."
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    echo "Git global configuration has been set up."
}

# Setup Git credential helper
setup_credential_helper() {
    echo "Setting up Git credential helper..."
    
    if [ "$DISTRO_FAMILY" = "debian" ] || [ "$DISTRO_FAMILY" = "ubuntu" ]; then
        # Check if libsecret is installed
        if dpkg -l | grep -q libsecret-1-0; then
            if [ -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]; then
                sudo ln -sf /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret /usr/local/bin/
                git config --global credential.helper libsecret
                echo "Git credential helper set to use libsecret."
            else
                sudo apt install -y libsecret-1-0 libsecret-1-dev
                cd /usr/share/doc/git/contrib/credential/libsecret
                sudo make
                sudo ln -sf /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret /usr/local/bin/
                git config --global credential.helper libsecret
                echo "Git credential helper set to use libsecret."
            fi
        else
            # If libsecret is not available, use cache
            git config --global credential.helper cache
            git config --global credential.helper 'cache --timeout=3600'
            echo "Git credential helper set to use cache with a timeout of 1 hour."
        fi
    elif [ "$DISTRO_FAMILY" = "redhat" ]; then
        if rpm -q libsecret &> /dev/null; then
            # Potential path for git-credential-libsecret
            if [ -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]; then
                sudo ln -sf /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret /usr/local/bin/
                git config --global credential.helper libsecret
                echo "Git credential helper set to use libsecret."
            else
                git config --global credential.helper cache
                git config --global credential.helper 'cache --timeout=3600'
                echo "Git credential helper set to use cache with a timeout of 1 hour."
            fi
        else
            git config --global credential.helper cache
            git config --global credential.helper 'cache --timeout=3600'
            echo "Git credential helper set to use cache with a timeout of 1 hour."
        fi
    elif [ "$DISTRO_FAMILY" = "arch" ]; then
        if pacman -Q libsecret &> /dev/null; then
            git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
            echo "Git credential helper set to use libsecret."
        else
            git config --global credential.helper cache
            git config --global credential.helper 'cache --timeout=3600'
            echo "Git credential helper set to use cache with a timeout of 1 hour."
        fi
    else
        git config --global credential.helper cache
        git config --global credential.helper 'cache --timeout=3600'
        echo "Git credential helper set to use cache with a timeout of 1 hour."
    fi
}

# Setup SSH key for Git
setup_ssh_key() {
    echo "Checking for existing SSH keys..."
    
    if [ -f "$HOME/.ssh/id_rsa" ] || [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo "Existing SSH keys found."
        read -p "Do you want to generate a new SSH key? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            echo "Skipping SSH key generation."
            return
        fi
    fi
    
    # Ask for SSH key type
    echo "Select SSH key type:"
    echo "1. RSA (compatible with older systems)"
    echo "2. Ed25519 (more secure, recommended for newer systems)"
    read -p "Choice [2]: " key_type_choice
    key_type_choice=${key_type_choice:-2}
    
    case $key_type_choice in
        1)
            key_type="rsa"
            key_size="4096"
            key_file="$HOME/.ssh/id_rsa"
            ;;
        2)
            key_type="ed25519"
            key_file="$HOME/.ssh/id_ed25519"
            ;;
        *)
            echo "Invalid choice. Using Ed25519."
            key_type="ed25519"
            key_file="$HOME/.ssh/id_ed25519"
            ;;
    esac
    
    # Ask for email address for SSH key
    read -p "Enter your email for the SSH key (default: use Git email): " ssh_email
    if [ -z "$ssh_email" ]; then
        ssh_email=$(git config --global user.email)
        if [ -z "$ssh_email" ]; then
            read -p "No Git email found. Please enter an email for the SSH key: " ssh_email
            if [ -z "$ssh_email" ]; then
                echo "Email is required for SSH key generation. Aborting."
                return 1
            fi
        fi
    fi
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate SSH key
    echo "Generating SSH key..."
    if [ "$key_type" = "rsa" ]; then
        ssh-keygen -t rsa -b $key_size -C "$ssh_email" -f "$key_file"
    else
        ssh-keygen -t ed25519 -C "$ssh_email" -f "$key_file"
    fi
    
    if [ $? -ne 0 ]; then
        echo "Failed to generate SSH key."
        return 1
    fi
    
    # Add the key to SSH agent
    eval "$(ssh-agent -s)"
    ssh-add "$key_file"
    
    # Display the public key
    echo "Your public SSH key:"
    cat "$key_file.pub"
    echo ""
    echo "Add this key to your GitHub/GitLab/Bitbucket account."
    read -p "Press Enter to continue..."
    
    echo "SSH key setup complete."
}

# Setup LFS hooks
setup_git_lfs() {
    echo "Setting up Git LFS..."
    
    # Check if Git LFS is installed
    if ! command -v git-lfs &> /dev/null; then
        echo "Git LFS is not installed. Installing..."
        
        case $DISTRO_FAMILY in
            debian)
                sudo apt update
                sudo apt install -y git-lfs
                ;;
            redhat)
                sudo dnf install -y git-lfs
                ;;
            arch)
                sudo pacman -S --noconfirm git-lfs
                ;;
            suse)
                sudo zypper install -y git-lfs
                ;;
            *)
                echo "Unsupported distribution for automatic Git LFS installation."
                echo "Please install Git LFS manually."
                return 1
                ;;
        esac
    fi
    
    # Initialize Git LFS
    git lfs install --skip-repo
    
    echo "Git LFS has been set up."
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Set up Git global configuration
    setup_git_config
    
    # Set up Git credential helper
    setup_credential_helper
    
    # Ask if user wants to set up SSH key
    read -p "Do you want to set up an SSH key for Git? (y/N): " ssh_choice
    if [[ $ssh_choice =~ ^[Yy]$ ]]; then
        setup_ssh_key
    else
        echo "Skipping SSH key setup."
    fi
    
    # Set up Git LFS
    read -p "Do you want to set up Git LFS (Large File Storage)? (y/N): " lfs_choice
    if [[ $lfs_choice =~ ^[Yy]$ ]]; then
        setup_git_lfs
    else
        echo "Skipping Git LFS setup."
    fi
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        current_version=$(git --version | awk '{print $3}')
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
        new_version=$(git --version | awk '{print $3}')
        echo "Version: $new_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up Git configuration? (Y/n): " config_choice
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
    
    # Ask to remove Git
    read -p "Are you sure you want to remove Git? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Remove Git based on distribution family
        case $DISTRO_FAMILY in
            debian)
                sudo apt remove -y git git-lfs git-flow tig gitg meld
                ;;
            redhat)
                sudo dnf remove -y git git-lfs git-flow-avh tig gitg meld
                ;;
            arch)
                sudo pacman -Rs --noconfirm git git-lfs git-flow tig gitg meld
                ;;
            suse)
                sudo zypper remove -y git git-lfs git-flow tig gitg meld
                ;;
            *)
                echo "Unsupported distribution for automatic uninstallation."
                echo "Please uninstall Git manually."
                ;;
        esac
        
        # Ask to remove configuration files
        read -p "Do you want to remove Git configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            # Backup .gitconfig
            if [ -f "$HOME/.gitconfig" ]; then
                echo "Backing up .gitconfig before removal..."
                cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d-%H%M%S)"
                rm "$HOME/.gitconfig"
                echo "Removed .gitconfig"
            fi
            
            # Remove config directory
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                rm -rf "$PACKAGE_DOTFILES_DIR"
                echo "Removed Git configuration directory"
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