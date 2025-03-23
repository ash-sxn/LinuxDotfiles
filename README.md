# LinuxDotfiles

A comprehensive collection of Linux configuration files, setup scripts, and utilities to make migrating between distributions seamless. This repository contains configuration files and setup scripts to replicate your preferred environment on any Linux distribution, with a focus on migration from Ubuntu to Arch Linux.

## Repository Contents

* `.config/`: Configuration files from various applications
* `home_dotfiles/`: Dotfiles from your home directory (like .bashrc, .zshrc)
* `system_config/`: System configuration files
* `arch_setup.sh`: Script for setting up a new Arch Linux system
* `collect_dotfiles.sh`: Script to gather and backup your dotfiles
* `MIGRATION.md`: Guide for migrating from Ubuntu to Arch Linux

## Package Management Systems

This setup includes packages from multiple sources:
- APT (Debian/Ubuntu package manager)
- Snap (Canonical's package distribution system)
- Flatpak (Distribution-independent package format)
- AUR (Arch User Repository, for Arch-based distros)

## Applications & Dotfiles

Below is a comprehensive list of applications that will be installed in your new system setup.

### Terminal & Shell

- [x] kitty (Terminal emulator) - *Backed up*
- [x] tmux (Terminal multiplexer) - *Backed up*
- [x] zsh (Z shell) - *Backed up*
- [x] Oh My ZSH (ZSH framework)
- [x] nvim (Neovim text editor) - *Backed up*

### Development Tools

- [x] Git - *Backed up*
- [x] GitHub CLI (gh) - *Backed up*
- [x] curl, wget (download utilities)
- [x] Docker/Containerd
- [x] Cursor (AI-powered IDE)

#### VS Code Extensions
- GitHub Copilot
- GitHub Copilot Chat
- Go
- Python
- Remote Development Extensions
- C/C++ Tools
- Docker
- Cody AI
- PDF Viewer
- CSV Tools

### Browsers

- [x] Brave Browser - *Backed up*
- [x] Firefox (Snap)

### Productivity & Utilities

- [x] CopyQ (Clipboard manager) - *Backed up* (Looking for better alternatives)
- [x] Ulauncher (Application launcher) - *Backed up*
- [x] Slack (Flatpak)
- [x] Signal (Secure messaging app)
- [x] Upwork (Freelancing platform)

### Multimedia

- [x] MPV (Media player)
- [x] VLC (Media player)

### System Tools

- [x] bridge-utils (Network utilities for managing bridge connections)
- [x] bluetooth (Bluetooth connectivity tools)
- [x] Free Download Manager (or open-source alternative)

## GNOME Desktop Environment

Will be configured separately in detail later.

## Instructions for Use

### Backing Up Your Dotfiles

1. Clone this repository:
   ```bash
   git clone https://github.com/ash-sxn/LinuxDotfiles.git
   cd LinuxDotfiles
   ```

2. Run the collection script to gather your configuration files:
   ```bash
   chmod +x collect_dotfiles.sh
   ./collect_dotfiles.sh
   ```

3. Review the collected files and push to your GitHub:
   ```bash
   cd ~/dotfiles_backup
   ./push_to_github.sh
   ```

### Setting Up a New System

1. Clone this repository on your new system:
   ```bash
   git clone https://github.com/ash-sxn/LinuxDotfiles.git
   cd LinuxDotfiles
   ```

2. For Arch Linux setup, run:
   ```bash
   chmod +x arch_setup.sh
   ./arch_setup.sh
   ```

3. For detailed migration instructions, refer to `MIGRATION.md`.

## Notes

- Configuration files may need adjustments for different Linux distributions
- Check the compatibility of your packages with your target distribution
- Always review configuration files before applying them to a new system

## Clipboard Manager Alternatives

Some better alternatives to CopyQ and Keepboard:

1. **Clipman** - Lightweight, Wayland-compatible clipboard manager
2. **Clipit** - GTK-based clipboard manager with good feature set
3. **Klipper** - KDE clipboard manager (if you ever use KDE)
4. **GPaste** - GNOME Shell compatible clipboard manager with good integration

## System Tools Explained

- **bridge-utils**: Used for configuring network bridge interfaces in Linux. Helpful if you use virtual machines or containers that need to share your network connection. In Arch Linux, install with `pacman -S bridge-utils`.

- **bluetooth**: Tools for handling Bluetooth connections. In Arch Linux, you'll need the `bluez` and `bluez-utils` packages, installed with `pacman -S bluez bluez-utils`. You'll also need to enable the Bluetooth service with `systemctl enable bluetooth.service`.

## Download Manager Options

- **Free Download Manager**: Not fully open-source. Some alternatives:
  - **uGet**: Open-source download manager with good features
  - **aria2**: Command-line download utility with web UIs available
  - **JDownloader**: Java-based download manager with extensive features
  - **XDM (Xtreme Download Manager)**: Open-source alternative with browser integration

## Next Steps

1. For each application, we'll create installation scripts that work across different Linux distributions
2. We'll handle GNOME desktop configuration separately
3. The collect_dotfiles.sh script will be updated to ensure all necessary configuration files are backed up
