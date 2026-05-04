#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$ROOT/dotfiles"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi
}

link_file() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  backup_if_exists "$target"
  ln -s "$source" "$target"
}

link_dir() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  backup_if_exists "$target"
  ln -s "$source" "$target"
}

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed. Install Homebrew first, then rerun this script."
  exit 1
fi

echo "Installing Homebrew bundle..."
brew bundle --file "$ROOT/Brewfile"

echo "Installing Oh My Zsh and Powerlevel10k if missing..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

echo "Linking portable configs..."
link_dir "$DOTFILES/config/ghostty" "$HOME/.config/ghostty"
link_dir "$DOTFILES/config/nvim" "$HOME/.config/nvim"
link_dir "$DOTFILES/config/tmux" "$HOME/.config/tmux"
link_file "$DOTFILES/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

echo
echo "Done. Merge zsh manually from:"
echo "  $DOTFILES/home/.zshrc"
echo "  $DOTFILES/config/zsh/.zshrc"
echo
echo "Recommended Ghostty font: MesloLGS NF or JetBrainsMono Nerd Font."
