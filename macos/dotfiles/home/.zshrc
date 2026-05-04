# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Basic zsh configuration
ZDOTDIR=$HOME

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME=""

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Plugin configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Basic plugins
plugins=(git)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Initialize completion
autoload -U compinit && compinit

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

# Completion configuration
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# Useful aliases
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias cleanup='sudo pacman -Qtdq | sudo pacman -Rns -'
alias kiro='kiro-ai-editor'

# Load FZF if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Key bindings
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[3;5~' backward-kill-word

# Test alias
alias testcmd="echo 'alias works!'"
#Alias
alias copy="wl-copy"
alias paste="wl-paste"


# Print confirmation
echo "zshrc loaded successfully!"

###############################################################################
# End of .zshrc
source ~/powerlevel10k/powerlevel10k.zsh-theme
if ! pgrep -x "fcitx" >/dev/null; then fcitx -d fcitx -d & ; fi
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
