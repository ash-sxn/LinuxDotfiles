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

Below is a comprehensive list of applications installed on your system. Check the boxes for applications that need custom configuration files to be backed up.

### Terminal & Shell

- [ ] kitty (Terminal emulator) - *Backed up*
- [ ] tmux (Terminal multiplexer) - *Backed up*
- [ ] zsh (Z shell) - *Backed up*
- [ ] bash (Bourne Again SHell) - *Backed up*
- [ ] nvim (Neovim text editor) - *Backed up*

### Development Tools

- [ ] Git - *Backed up*
- [ ] GitHub CLI (gh) - *Backed up*
- [ ] VS Code - *Backed up*
- [ ] VS Code Insiders
- [ ] build-essential (development tools)
- [ ] cmake
- [ ] curl, wget (download utilities)
- [ ] Docker/Containerd

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

- [ ] Brave Browser - *Backed up*
- [ ] Chromium (Snap)
- [ ] Firefox (Snap)

### Productivity & Utilities

- [ ] CopyQ (Clipboard manager) - *Backed up*
- [ ] Keepboard (from Snap)
- [ ] Ulauncher (Application launcher) - *Backed up*
- [ ] Telegram (Flatpak)
- [ ] Slack (Flatpak)
- [ ] Whatsapp for Linux (Snap)
- [ ] AnyDesk (Remote desktop)
- [ ] dconf-editor (GNOME configuration tool)

### Multimedia

- [ ] DuckStation (PlayStation emulator, Flatpak)
- [ ] Mednaffe (Frontend for Mednafen emulator, Flatpak)
- [ ] Steam (Gaming platform, Snap)

### System Tools

- [ ] baobab (Disk usage analyzer)
- [ ] Firmware Updater (Snap)
- [ ] aria2 (Download utility)
- [ ] bridge-utils (Network utilities)
- [ ] bluetooth (Bluetooth tools)
- [ ] Woe-USB (Create Windows bootable USB, Snap)

### GNOME Desktop Environment

- [ ] GNOME Shell - *Backed up*
- [ ] GNOME Session - *Backed up*
- [ ] GNOME Tweaks
- [ ] GTK 3.0/4.0 Themes - *Backed up*
- [ ] HydraPaper (Wallpaper manager, Flatpak)

### Other Applications

- [ ] Fagram (Snap)
- [ ] Komikku (Manga reader, Flatpak)
- [ ] Proton Up QT (Proton manager for Steam, Flatpak)
- [ ] Wayback (Internet Archive client, Flatpak)
- [ ] Telega (Snap)

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

## Customization Checklist

For each application in the list above:
1. Mark the checkbox if you need to back up its custom configuration
2. Review existing configuration in `~/.config/` and other locations
3. Update the collect_dotfiles.sh script to include additional directories if needed
