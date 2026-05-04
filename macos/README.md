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

## Post-install checklist

After `brew bundle` and `./install.sh`, finish these manually on a fresh Mac:

- Install or finish Docker Desktop if Homebrew stops on the privileged
  `/usr/local/cli-plugins` step.
- Run `gh auth login` again if GitHub CLI auth did not carry over.
- Create a real `~/.gitconfig` with your actual name and email. Do not copy the
  placeholder values from `dotfiles/home/.gitconfig`.
- Install tmux TPM if you want the tmux plugins from `tmux.conf`:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

- Open Neovim once and let it finish plugin bootstrap if needed.

## Notes from the 2026 MacBook Air setup

The first full setup on macOS 26.4.1 required two repo-level fixes:

- `upwork` was removed from `Brewfile` because the cask no longer exists in
  Homebrew.
- `cmp-async-path` was pinned through GitHub in the custom Neovim plugin list
  because the upstream NvChad reference used a Codeberg URL that was not
  reachable in this environment.

See [SETUP-2026-05-04.md](./SETUP-2026-05-04.md) for the exact machine notes and
[SHORTCUTS.md](./SHORTCUTS.md) for the macOS keyboard refresher.

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
