# macOS migration bundle

This folder contains the small workstation configs to pull onto the MacBook.
It is intentionally separate from the older Linux setup scripts.

## What is included

- `dotfiles/home/`: reference home dotfiles from the Arch machine.
- `dotfiles/config/ghostty/`: Ghostty config and Catppuccin themes.
- `dotfiles/config/nvim/`: Neovim config without its `.git` folder or plugin cache.
- `dotfiles/config/tmux/`: tmux config.
- `dotfiles/config/zsh/`: alternate zsh config and Powerlevel10k prompt config.
- `Brewfile`: Mac apps and CLI packages from the keep list.
- `install.sh`: optional helper that installs Homebrew packages and links selected configs.

## Before running on the Mac

Review these files manually before linking:

- `dotfiles/home/.zshrc`
- `dotfiles/config/zsh/.zshrc`
- `dotfiles/home/.gitconfig`

The zsh files were copied from Linux and contain Linux-specific pieces such as
`pacman`, `wl-copy`, `fcitx`, `systemd`, and Arch plugins. Treat them as merge
references for your existing Mac shell config.

## Suggested Mac setup

Install Homebrew first if needed:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then from this repo:

```sh
cd macos
brew bundle --file Brewfile
./install.sh
```

The install script does not overwrite existing files without making a timestamped
backup first.

## Not included

These are deliberately excluded and should be migrated manually:

- SSH keys and `~/.ssh/config`
- GPG keys
- shell history
- `.env*` files
- `.npmrc`
- browser profiles
- app auth databases and token stores
- Vercel, GitHub, cloud, and editor auth tokens
