#!/bin/bash

# Wikiman installation script (https://github.com/filiparag/wikiman)

# Package information
PACKAGE_NAME="Wikiman"
PACKAGE_DESCRIPTION="An offline search engine for manual pages, Arch Wiki, and other documentation"
PACKAGE_DOTFILES_DIR="$HOME/.config/wikiman"

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

# Check if the package is already installed
is_installed() {
    if command -v wikiman &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Install dependencies common for all distributions
install_common_deps() {
    echo "Checking for dependencies..."
    
    # List of dependencies
    local deps=("fzf" "ripgrep" "w3m" "parallel")
    local missing_deps=()
    
    # Check if dependencies are installed
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    # Install missing dependencies based on distribution
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Installing missing dependencies: ${missing_deps[*]}"
        
        case $DISTRO_FAMILY in
            debian)
                sudo apt update
                sudo apt install -y "${missing_deps[@]}"
                ;;
            redhat)
                sudo dnf install -y "${missing_deps[@]}"
                ;;
            arch)
                sudo pacman -S --noconfirm "${missing_deps[@]}"
                ;;
            suse)
                sudo zypper install -y "${missing_deps[@]}"
                ;;
            *)
                echo "Warning: Unable to automatically install dependencies."
                echo "Please install the following manually: ${missing_deps[*]}"
                ;;
        esac
    fi
}

# Install optional documentation sources
install_doc_sources() {
    echo "Installing additional documentation sources for wikiman..."
    
    # Create a temporary directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1
    
    # Download the latest Makefile from the wikiman repository
    curl -L 'https://raw.githubusercontent.com/filiparag/wikiman/master/Makefile' -o 'wikiman-makefile'
    
    # Install Arch Wiki source
    echo "Installing Arch Wiki documentation..."
    make -f ./wikiman-makefile source-arch
    sudo make -f ./wikiman-makefile source-install
    
    # Install TLDR source
    echo "Installing TLDR documentation..."
    make -f ./wikiman-makefile source-tldr
    sudo make -f ./wikiman-makefile source-install
    
    # Install FreeBSD documentation
    echo "Installing FreeBSD documentation..."
    make -f ./wikiman-makefile source-fbsd
    sudo make -f ./wikiman-makefile source-install
    
    # Clean up
    sudo make -f ./wikiman-makefile clean
    cd - > /dev/null || exit 1
    rm -rf "$tmp_dir"
    
    echo "Documentation sources installed successfully."
}

# Install package on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Check if wikiman is available in the repositories
    if apt-cache search --names-only ^wikiman$ | grep -q wikiman; then
        sudo apt update
        sudo apt install -y wikiman
    else
        # Install from source
        local tmp_dir
        tmp_dir=$(mktemp -d)
        cd "$tmp_dir" || exit 1
        
        echo "Installing from source..."
        git clone https://github.com/filiparag/wikiman.git
        cd wikiman || exit 1
        
        # Switch to latest stable version
        git checkout "$(git describe --tags | cut -d'-' -f1)"
        
        # Install
        make all
        sudo make install
        
        # Clean up
        cd - > /dev/null || exit 1
        rm -rf "$tmp_dir"
    fi
    
    # Install additional documentation sources
    install_doc_sources
}

# Install package on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # Try to install from dnf repositories first
    if dnf list wikiman &> /dev/null; then
        sudo dnf install -y wikiman
    else
        # Install from source
        local tmp_dir
        tmp_dir=$(mktemp -d)
        cd "$tmp_dir" || exit 1
        
        echo "Installing from source..."
        git clone https://github.com/filiparag/wikiman.git
        cd wikiman || exit 1
        
        # Switch to latest stable version
        git checkout "$(git describe --tags | cut -d'-' -f1)"
        
        # Install
        make all
        sudo make install
        
        # Clean up
        cd - > /dev/null || exit 1
        rm -rf "$tmp_dir"
    fi
    
    # Install additional documentation sources
    install_doc_sources
}

# Install package on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    # Install from official repositories
    sudo pacman -S --noconfirm wikiman
    
    # Install arch-wiki-docs package
    sudo pacman -S --noconfirm arch-wiki-docs
    
    # Install additional documentation sources (TLDR and FreeBSD)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1
    
    # Download the latest Makefile from the wikiman repository
    curl -L 'https://raw.githubusercontent.com/filiparag/wikiman/master/Makefile' -o 'wikiman-makefile'
    
    # Install TLDR source
    echo "Installing TLDR documentation..."
    make -f ./wikiman-makefile source-tldr
    sudo make -f ./wikiman-makefile source-install
    
    # Install FreeBSD documentation
    echo "Installing FreeBSD documentation..."
    make -f ./wikiman-makefile source-fbsd
    sudo make -f ./wikiman-makefile source-install
    
    # Clean up
    sudo make -f ./wikiman-makefile clean
    cd - > /dev/null || exit 1
    rm -rf "$tmp_dir"
}

# Install package on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    # Try to install from zypper repositories first
    if zypper search -x wikiman | grep -q "^wikiman "; then
        sudo zypper install -y wikiman
    else
        # Install from source
        local tmp_dir
        tmp_dir=$(mktemp -d)
        cd "$tmp_dir" || exit 1
        
        echo "Installing from source..."
        git clone https://github.com/filiparag/wikiman.git
        cd wikiman || exit 1
        
        # Switch to latest stable version
        git checkout "$(git describe --tags | cut -d'-' -f1)"
        
        # Install
        make all
        sudo make install
        
        # Clean up
        cd - > /dev/null || exit 1
        rm -rf "$tmp_dir"
    fi
    
    # Install additional documentation sources
    install_doc_sources
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    
    # Install from source
    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1
    
    echo "Installing from source..."
    git clone https://github.com/filiparag/wikiman.git
    cd wikiman || exit 1
    
    # Switch to latest stable version
    git checkout "$(git describe --tags | cut -d'-' -f1)"
    
    # Install
    make all
    sudo make install
    
    # Clean up
    cd - > /dev/null || exit 1
    rm -rf "$tmp_dir"
    
    # Install additional documentation sources
    install_doc_sources
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create default config file if it doesn't exist
    if [ ! -f "$PACKAGE_DOTFILES_DIR/wikiman.conf" ]; then
        cat > "$PACKAGE_DOTFILES_DIR/wikiman.conf" << 'EOF'
# Wikiman configuration file

# Sources (enable all available)
sources = man, arch, tldr, fbsd

# Fuzzy finder
fuzzy_finder = fzf

# Quick search mode (only by title)
quick_search = true

# Raw output (for developers)
raw_output = false

# Manpages language(s)
man_lang = en

# Wiki language(s)
wiki_lang = en

# Show previews in TUI
tui_preview = true

# Keep open after viewing a result
tui_keep_open = true

# Show source column
tui_source_column = true

# Viewer for HTML pages
tui_html = w3m
EOF
    fi
    
    # Add shell widget to .zshrc if user is using zsh
    if [ -f "$HOME/.zshrc" ] && command -v zsh &> /dev/null; then
        if ! grep -q "source /usr/share/wikiman/widgets/widget.zsh" "$HOME/.zshrc"; then
            echo "# Wikiman shell widget (Ctrl+F)" >> "$HOME/.zshrc"
            echo "source /usr/share/wikiman/widgets/widget.zsh" >> "$HOME/.zshrc"
        fi
    fi
    
    # Add shell widget to .bashrc if user is using bash
    if [ -f "$HOME/.bashrc" ] && command -v bash &> /dev/null; then
        if ! grep -q "source /usr/share/wikiman/widgets/widget.bash" "$HOME/.bashrc"; then
            echo "# Wikiman shell widget (Ctrl+F)" >> "$HOME/.bashrc"
            echo "source /usr/share/wikiman/widgets/widget.bash" >> "$HOME/.bashrc"
        fi
    fi
    
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
            setup_config
            return
        fi
    fi
    
    # Install common dependencies
    install_common_deps
    
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
    
    # Uninstall based on distribution family
    case $DISTRO_FAMILY in
        debian)
            sudo apt remove -y wikiman
            ;;
        redhat)
            sudo dnf remove -y wikiman
            ;;
        arch)
            sudo pacman -Rs --noconfirm wikiman
            sudo pacman -Rs --noconfirm arch-wiki-docs
            ;;
        suse)
            sudo zypper remove -y wikiman
            ;;
        *)
            echo "Removing manually installed wikiman..."
            sudo rm -f /usr/local/bin/wikiman
            sudo rm -rf /usr/local/share/wikiman
            sudo rm -f /usr/local/share/man/man1/wikiman.1
            ;;
    esac
    
    # Backup and remove config files
    if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
        echo "Backing up configuration files..."
        backup_dir="$HOME/.config/backup/wikiman"
        mkdir -p "$backup_dir"
        cp -r "$PACKAGE_DOTFILES_DIR" "$backup_dir"
        
        read -p "Do you want to remove configuration files? (y/N): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            rm -rf "$PACKAGE_DOTFILES_DIR"
            echo "Configuration files removed."
        fi
    fi
    
    # Remove shell widget from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/# Wikiman shell widget/d' "$HOME/.zshrc"
        sed -i '/source \/usr\/share\/wikiman\/widgets\/widget.zsh/d' "$HOME/.zshrc"
    fi
    
    # Remove shell widget from .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# Wikiman shell widget/d' "$HOME/.bashrc"
        sed -i '/source \/usr\/share\/wikiman\/widgets\/widget.bash/d' "$HOME/.bashrc"
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