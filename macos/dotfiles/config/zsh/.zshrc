# Set the oh-my-zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Set your theme to Powerlevel10k
# (Ensure you have installed Powerlevel10k in ~/.oh-my-zsh/custom/themes/powerlevel10k)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable auto-correction, completion waiting dots, and disable VCS dirty marking
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Define plugins for maximum productivity
plugins=(
  git
  systemadmin
  history
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
  systemd
  archlinux
  sudo
  kubectl
  docker
  docker-compose
)

# Load oh-my-zsh (this also initializes many completions via compinit)
source $ZSH/oh-my-zsh.sh

# (Optional) Ensure autocompletion is enabled
autoload -U compinit && compinit

# Powerlevel10k instant prompt (speeds up prompt rendering)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Powerlevel10k configuration if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enhanced History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY       # Use ":start:elapsed;command" format
setopt INC_APPEND_HISTORY     # Write history as commands are entered
setopt SHARE_HISTORY          # Share history across sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicate entries
setopt HIST_REDUCE_BLANKS      # Remove extra blanks

# Advanced Autocompletion settings
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion
zstyle ':completion:*' menu select                         # Interactive menu

# Productivity Aliases
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias cleanup='sudo pacman -Qtdq | sudo pacman -Rns -'

# FZF Configuration (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Additional PATH adjustments
export PATH=$HOME/.config/rofi/scripts:$PATH

###############################################################################
# Custom Keybindings
###############################################################################

# Ensure Ctrl+P and Ctrl+N work as previous and next history commands.
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

# Bind Ctrl+Left and Ctrl+Right arrow keys to jump backward and forward by a word.
# (These escape sequences are common, but may vary depending on your terminal.)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Bind Ctrl+Backspace to delete the entire word.
# (This escape sequence is common; adjust if needed.)
bindkey '^[[3;5~' backward-kill-word

###############################################################################
# End of .zshrc

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# zstype for zsh-completion modifications 
# Better completion settings
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '(#i)*POWERLEVEL9K_*'  # Hide Powerlevel9k variables
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands  # Order of completion items
zstyle ':completion:*' completer _expand _complete _ignored  # Completion behavior
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'  # Green headers for completion sections
zstyle ':completion:*' menu select  # Interactive menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion
zstyle ':completion:*' group-name ''  # Group similar items
zstyle ':completion:*' special-dirs true  # Complete special directories

. "$HOME/.local/bin/env"
