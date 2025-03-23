# LinuxDotfiles

A collection of Linux configuration files and setup scripts for personal use. This project aims to make it easier to set up a new Linux system with preferred applications and configurations.

## Project Structure

The repository is organized into a modular structure:

```
LinuxDotfiles/
├── install.sh                # Main installation script
├── packages/                 # Package installation scripts
│   ├── terminal/             # Terminal applications
│   ├── development/          # Development tools
│   ├── browsers/             # Web browsers
│   ├── productivity/         # Productivity applications
│   ├── multimedia/           # Media players and editors
│   └── system/               # System utilities and tools
├── template.sh               # Template for package installation scripts
└── README.md                 # This file
```

Each package folder contains:
- `install.sh` - Installation script that works across major Linux distributions
- `config_setup.sh` - Script to set up configuration files
- `config/` - Directory containing configuration files and dotfiles
- `description.txt` - Description of the package

## Features

- **Cross-distribution Compatibility**: Installation scripts designed to work across major Linux distributions (Debian/Ubuntu, Arch, Fedora, openSUSE)
- **Modular Design**: Each application has its own directory with installation and configuration scripts
- **Easy Selection**: Interactive menu to select which applications to install
- **Automatic Configuration**: Option to automatically set up configuration files for installed applications

## Supported Applications

### Terminal Applications
- Zsh with Oh My Zsh
- Tmux
- Neovim
- Alacritty

### Development Tools
- Git
- Visual Studio Code
- Go Programming Language
- Docker

### Browsers
- Firefox
- Google Chrome
- Chromium

### Productivity Applications
- GPaste (Clipboard Manager)
- Cursor (AI IDE)
- LibreOffice

### Multimedia
- MPV
- VLC
- GIMP

### System Utilities
- Bridge Utils
- Bluetooth Tools
- Network Manager

## Usage

To use this repository, clone it and run the main installation script:

```bash
git clone https://github.com/yourusername/LinuxDotfiles.git
cd LinuxDotfiles
chmod +x install.sh
./install.sh
```

The script will guide you through the installation process.

## Adding New Packages

To add a new package:

1. Create a new directory in the appropriate category (e.g., `packages/development/newpackage`)
2. Copy the template script: `cp template.sh packages/development/newpackage/install.sh`
3. Modify the installation script for the specific package
4. Create a configuration setup script if needed
5. Add configuration files to the `config/` directory

## Contributing

Contributions are welcome! Feel free to add new package installation scripts or improve existing ones.

## License

This project is open source and available under the MIT License.
