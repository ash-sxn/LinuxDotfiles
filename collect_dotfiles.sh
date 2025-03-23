#!/bin/bash

# collect_dotfiles.sh
# Script to collect important configuration files from your system
# and organize them for backup to GitHub

echo "Starting dotfiles collection process..."

# Create a backup directory structure
BACKUP_DIR="$HOME/dotfiles_backup"
CONFIG_DIR="$BACKUP_DIR/.config"
HOME_DOTFILES="$BACKUP_DIR/home_dotfiles"
SYSTEM_CONFIG="$BACKUP_DIR/system_config"

# Create directories
mkdir -p "$CONFIG_DIR" "$HOME_DOTFILES" "$SYSTEM_CONFIG"

# Function to copy a file/directory and maintain its relative path
backup_file() {
    local source_path="$1"
    local dest_dir="$2"
    
    if [ -e "$source_path" ]; then
        # Create parent directory if it doesn't exist
        mkdir -p "$(dirname "$dest_dir/$source_path")"
        cp -r "$source_path" "$dest_dir/$source_path"
        echo "Backed up: $source_path"
    else
        echo "Warning: $source_path does not exist, skipping"
    fi
}

# Backup common user configuration directories
echo "Backing up .config directory..."
for dir in "$HOME/.config/kitty" "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.config/pulse" \
           "$HOME/.config/alacritty" "$HOME/.config/i3" "$HOME/.config/sway" "$HOME/.config/ulauncher" \
           "$HOME/.config/copyq" "$HOME/.config/Code" "$HOME/.config/gh" "$HOME/.config/brave" \
           "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/dconf" \
           "$HOME/.config/gnome-session" "$HOME/.config/gnome-shell"; do
    if [ -d "$dir" ]; then
        target_dir="$(echo "$dir" | sed "s|$HOME|$BACKUP_DIR|")"
        mkdir -p "$(dirname "$target_dir")"
        cp -r "$dir" "$(dirname "$target_dir")"
        echo "Backed up: $dir"
    fi
done

# Backup common home dotfiles
echo "Backing up home dotfiles..."
for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile" \
            "$HOME/.vimrc" "$HOME/.tmux.conf" "$HOME/.gitconfig" "$HOME/.xinitrc" \
            "$HOME/.Xresources" "$HOME/.xprofile" "$HOME/.inputrc"; do
    if [ -f "$file" ]; then
        cp "$file" "$HOME_DOTFILES/$(basename "$file")"
        echo "Backed up: $file"
    fi
done

# Backup important system files (requires sudo)
echo "Backing up important system files (requires sudo)..."
for file in "/etc/fstab" "/etc/default/grub" "/etc/X11/xorg.conf" "/etc/X11/xorg.conf.d"; do
    if [ -e "$file" ]; then
        sudo cp -r "$file" "$SYSTEM_CONFIG/"
        sudo chown -R "$(whoami):$(whoami)" "$SYSTEM_CONFIG/$(basename "$file")"
        echo "Backed up: $file"
    fi
done

# Export dconf settings
echo "Exporting dconf settings..."
dconf dump / > "$CONFIG_DIR/dconf_settings.ini"

# Find and backup VS Code extensions
if command -v code >/dev/null 2>&1; then
    echo "Listing installed VS Code extensions..."
    code --list-extensions > "$CONFIG_DIR/vscode_extensions.txt"
fi

# Create a list of installed packages
echo "Creating list of installed packages..."
if command -v dpkg >/dev/null 2>&1; then
    # Debian/Ubuntu
    dpkg --get-selections | grep -v deinstall > "$BACKUP_DIR/installed_packages.txt"
elif command -v pacman >/dev/null 2>&1; then
    # Arch Linux
    pacman -Qe > "$BACKUP_DIR/installed_packages.txt"
fi

echo "Creating a list of manually installed packages..."
apt-mark showmanual > "$BACKUP_DIR/manual_packages.txt" 2>/dev/null || true

# Create a script for Arch Linux installation
echo "Creating Arch Linux setup script..."
cat > "$BACKUP_DIR/arch_setup.sh" << 'EOF'
#!/bin/bash

# Arch Linux setup script
# This will install packages and set up your environment on a fresh Arch Linux installation

echo "Setting up Arch Linux environment..."

# Update the system
sudo pacman -Syu --noconfirm

# Install essential tools
sudo pacman -S --noconfirm base-devel git curl wget

# Install applications equivalent to your Ubuntu setup
sudo pacman -S --noconfirm firefox gnome-shell gnome-terminal gnome-control-center gnome-tweaks

# Check if yay is installed (AUR helper)
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install apps from AUR
echo "Installing applications from AUR..."
yay -S --noconfirm brave-bin visual-studio-code-bin kitty copyq ulauncher 

# Install GitHub CLI
yay -S --noconfirm github-cli

# Create symbolic links for dotfiles
echo "Setting up dotfiles..."
# Run from the dotfiles directory
if [ -d "$HOME/dotfiles_backup/.config" ]; then
    for dir in "$HOME/dotfiles_backup/.config"/*; do
        if [ -d "$dir" ]; then
            target="$HOME/.config/$(basename "$dir")"
            echo "Linking: $dir -> $target"
            mkdir -p "$(dirname "$target")"
            ln -sf "$dir" "$target"
        fi
    done
fi

# Link home dotfiles
if [ -d "$HOME/dotfiles_backup/home_dotfiles" ]; then
    for file in "$HOME/dotfiles_backup/home_dotfiles"/*; do
        if [ -f "$file" ]; then
            target="$HOME/.$(basename "$file")"
            echo "Linking: $file -> $target"
            ln -sf "$file" "$target"
        fi
    done
fi

# Install VS Code extensions
if [ -f "$HOME/dotfiles_backup/.config/vscode_extensions.txt" ]; then
    echo "Installing VS Code extensions..."
    while read extension; do
        code --install-extension "$extension" || true
    done < "$HOME/dotfiles_backup/.config/vscode_extensions.txt"
fi

# Import dconf settings
if [ -f "$HOME/dotfiles_backup/.config/dconf_settings.ini" ]; then
    echo "Importing dconf settings..."
    dconf load / < "$HOME/dotfiles_backup/.config/dconf_settings.ini"
fi

echo "Setup complete! Please restart your system for all changes to take effect."
EOF

chmod +x "$BACKUP_DIR/arch_setup.sh"

# Create a README file
cat > "$BACKUP_DIR/README.md" << 'EOF'
# Linux Dotfiles Backup

This directory contains a backup of your configuration files and system settings.

## Contents

- `.config/`: Configuration files from your home .config directory
- `home_dotfiles/`: Dotfiles from your home directory
- `system_config/`: System configuration files
- `installed_packages.txt`: List of installed packages
- `manual_packages.txt`: List of manually installed packages
- `arch_setup.sh`: Script to set up Arch Linux with your configurations

## Usage

1. To restore these files, copy them to their respective locations
2. For Arch Linux setup, run `./arch_setup.sh`
3. For system config files, carefully review and incorporate them into your new system

## Notes

- Some configuration files may need to be adjusted for the new system
- Review all configurations before applying them to a new system
EOF

echo "Creating a shell script to push files to GitHub..."
cat > "$BACKUP_DIR/push_to_github.sh" << 'EOF'
#!/bin/bash

# Script to push collected dotfiles to GitHub

REPO_NAME="linux_dotfiles"
GITHUB_USER=$(git config github.user)

if [ -z "$GITHUB_USER" ]; then
    echo "GitHub username not found in git config."
    echo "Please set your GitHub username with:"
    echo "  git config --global github.user YOUR_USERNAME"
    exit 1
fi

echo "Will push to GitHub repository: $GITHUB_USER/$REPO_NAME"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create temporary directory for the repository
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone the existing repository
git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git"
cd "$REPO_NAME"

# Copy all dotfiles to the repository
cp -r "$HOME/dotfiles_backup"/* .

# Commit and push changes
git add .
git commit -m "Update dotfiles $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "Dotfiles successfully pushed to GitHub!"
EOF

chmod +x "$BACKUP_DIR/push_to_github.sh"

echo "Dotfiles collection complete!"
echo "Your files have been backed up to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "1. Review the files in $BACKUP_DIR"
echo "2. Push them to GitHub using the provided script: $BACKUP_DIR/push_to_github.sh"
echo "3. On your new Arch Linux system, clone the repository and run arch_setup.sh" 