# Migration Guide: Ubuntu to Arch Linux

This guide will help you migrate from your current Ubuntu setup to a new Arch Linux installation with GNOME desktop environment, while preserving your configurations and data.

## Step 1: Backup Your Current System

First, collect all your important configuration files and data:

```bash
# Make the script executable
chmod +x collect_dotfiles.sh

# Run the collection script
./collect_dotfiles.sh
```

This will create a `dotfiles_backup` directory in your home folder with all your important configurations.

## Step 2: Back up Your Personal Data

Make sure to back up these additional important files:

1. **Documents, Photos, Music, Videos**: Copy your personal files to an external drive or cloud storage
2. **Browser data**: Export bookmarks and passwords from your browsers
3. **Email configurations**: Back up email client settings if applicable
4. **Database dumps**: If you use databases locally
5. **SSH keys**: Back up your `~/.ssh` directory
6. **GPG keys**: Export your GPG keys if you use them

## Step 3: Push Configuration to GitHub

After running the collection script, you can push your configuration files to GitHub:

```bash
cd ~/dotfiles_backup
./push_to_github.sh
```

This will create or update your `linux_dotfiles` repository on GitHub.

## Step 4: Install Arch Linux

1. Download the latest Arch Linux ISO from [archlinux.org](https://archlinux.org/download/)
2. Create a bootable USB using a tool like `dd` or Etcher
3. Boot from the USB and follow the [Arch Linux Installation Guide](https://wiki.archlinux.org/title/installation_guide)
4. For GNOME installation, follow these basic steps:

```bash
# After a base Arch installation and booting into the system:

# Install GNOME and essential packages
sudo pacman -S gnome gnome-tweaks gnome-shell-extensions gdm
sudo systemctl enable gdm.service
```

## Step 5: Restore Your Configuration

After installing Arch Linux and booting into your new system:

1. Clone your dotfiles repository:

```bash
git clone https://github.com/YOUR_USERNAME/linux_dotfiles.git
cd linux_dotfiles
```

2. Run the Arch setup script:

```bash
chmod +x arch_setup.sh
./arch_setup.sh
```

This will install all your applications and restore your configuration files.

## Step 6: Restore Your Personal Data

Copy all your personal data back from your backup drive or cloud storage to your new Arch Linux system.

## Common Issues and Solutions

### Fixing Display Brightness on Arch Linux

If you have brightness control issues similar to what you had on Ubuntu, check out the following resources:

- [Arch Wiki: Backlight](https://wiki.archlinux.org/title/backlight)
- The solution from your `brt.sol` file may need to be adapted for Arch Linux

### Setting Up Graphics Drivers

Arch Linux handles graphics drivers differently than Ubuntu. Follow these guidelines:

- For NVIDIA: [Arch Wiki: NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
- For AMD: [Arch Wiki: AMD](https://wiki.archlinux.org/title/AMD)
- For Intel: [Arch Wiki: Intel Graphics](https://wiki.archlinux.org/title/Intel_graphics)

### Package Management Differences

- Ubuntu uses `apt` for package management; Arch uses `pacman`
- For AUR (Arch User Repository) packages, you'll use `yay` (which we install in the setup script)

## Useful Arch Linux Commands

Here are some basic Arch Linux commands that replace commonly used Ubuntu commands:

| Ubuntu | Arch Linux | Description |
|--------|------------|-------------|
| `apt update` | `pacman -Sy` | Update package lists |
| `apt upgrade` | `pacman -Su` | Upgrade installed packages |
| `apt install package` | `pacman -S package` | Install a package |
| `apt remove package` | `pacman -R package` | Remove a package |
| `add-apt-repository ppa:...` | Use AUR (`yay -S package`) | Add a repository |

## Additional Resources

- [Arch Linux Wiki](https://wiki.archlinux.org/) - The best resource for Arch Linux
- [GNOME on Arch Linux](https://wiki.archlinux.org/title/GNOME)
- [AUR](https://aur.archlinux.org/) - Arch User Repository for additional packages
- [Arch Linux Forums](https://bbs.archlinux.org/) - Community support

## Troubleshooting

If you encounter issues during migration, the Arch Wiki is your best friend. For specific application problems, check:

1. Their official documentation
2. GitHub issues for the project
3. Arch Linux forums
4. Reddit communities like r/archlinux 