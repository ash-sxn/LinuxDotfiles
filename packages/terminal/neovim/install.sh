#!/bin/bash

# Neovim installation script

# Package information
PACKAGE_NAME="Neovim"
PACKAGE_DESCRIPTION="Hyperextensible Vim-based text editor"
PACKAGE_DOTFILES_DIR="$HOME/.config/nvim"

# Neovim version to install if using manual method
NVIM_VERSION="stable"

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        
        # Handle distribution families
        case $DISTRO in
            ubuntu|debian|linuxmint|pop|elementary|zorin)
                DISTRO_FAMILY="debian"
                ;;
            fedora|rhel|centos|rocky|alma)
                DISTRO_FAMILY="redhat"
                ;;
            arch|manjaro|endeavouros|artix|garuda)
                DISTRO_FAMILY="arch"
                ;;
            opensuse*)
                DISTRO_FAMILY="suse"
                ;;
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
    else
        DISTRO="unknown"
        DISTRO_FAMILY="unknown"
    fi
    
    echo "Detected distribution: $DISTRO (Family: $DISTRO_FAMILY)"
}

# Check if Neovim is already installed
is_installed() {
    if command -v nvim &> /dev/null; then
        return 0  # true, package is installed
    else
        return 1  # false, package is not installed
    fi
}

# Get latest Neovim release version
get_latest_release() {
    curl --silent "https://api.github.com/repos/neovim/neovim/releases/latest" | 
    grep '"tag_name":' | 
    sed -E 's/.*"v([^"]+)".*/\1/'
}

# Install Neovim on Debian-based systems
install_debian() {
    echo "Installing $PACKAGE_NAME on Debian-based system..."
    
    # Check if it's Ubuntu with version >= 22.04
    if [ "$DISTRO" = "ubuntu" ] && [ "$(echo "$VERSION_ID >= 22.04" | bc)" -eq 1 ]; then
        echo "Installing Neovim from Ubuntu official repositories..."
        sudo apt update
        sudo apt install -y neovim python3-neovim
    elif [ "$DISTRO" = "debian" ] && [ "$(echo "$VERSION_ID >= 12" | bc)" -eq 1 ]; then
        echo "Installing Neovim from Debian official repositories..."
        sudo apt update
        sudo apt install -y neovim python3-neovim
    else
        # For older versions, add the PPA (for Ubuntu) or use the AppImage method
        echo "Using alternative installation method for older distributions..."
        
        # Install dependencies
        sudo apt update
        sudo apt install -y curl wget unzip tar gzip gettext
        
        # Check if AppImage is a viable option
        if [ -z "$XDG_RUNTIME_DIR" ]; then
            echo "Installing via GitHub releases binary..."
            
            # Determine the latest version
            VERSION=$(get_latest_release)
            if [ -z "$VERSION" ]; then
                VERSION="0.9.4"  # Fallback to a known version
            fi
            
            # Download and extract Neovim
            wget -O /tmp/nvim-linux64.tar.gz "https://github.com/neovim/neovim/releases/download/v${VERSION}/nvim-linux64.tar.gz"
            sudo mkdir -p /opt/nvim
            sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt/nvim --strip-components=1
            sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
            
            rm -f /tmp/nvim-linux64.tar.gz
        else
            echo "Installing via AppImage..."
            
            # Download the AppImage
            mkdir -p $HOME/.local/bin
            curl -Lo $HOME/.local/bin/nvim https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
            chmod u+x $HOME/.local/bin/nvim
            
            # Add to PATH if not already there
            if ! echo $PATH | grep -q "$HOME/.local/bin"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
                export PATH="$HOME/.local/bin:$PATH"
            fi
        fi
    fi
    
    # Install dependencies for plugins (common ones)
    sudo apt install -y git ripgrep fd-find python3-pip
    sudo pip3 install pynvim
}

# Install Neovim on Red Hat-based systems
install_redhat() {
    echo "Installing $PACKAGE_NAME on Red Hat-based system..."
    
    # For Fedora, Neovim is in the official repositories
    if [ "$DISTRO" = "fedora" ]; then
        sudo dnf install -y neovim python3-neovim
    else
        # For other RedHat-based systems, use appimage or binary
        sudo dnf install -y curl wget tar gzip
        
        # Download and install Neovim binary
        VERSION=$(get_latest_release)
        if [ -z "$VERSION" ]; then
            VERSION="0.9.4"  # Fallback to a known version
        fi
        
        wget -O /tmp/nvim-linux64.tar.gz "https://github.com/neovim/neovim/releases/download/v${VERSION}/nvim-linux64.tar.gz"
        sudo mkdir -p /opt/nvim
        sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt/nvim --strip-components=1
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
        
        rm -f /tmp/nvim-linux64.tar.gz
    fi
    
    # Install dependencies for plugins (common ones)
    sudo dnf install -y git ripgrep fd-find python3-pip
    sudo pip3 install pynvim
}

# Install Neovim on Arch-based systems
install_arch() {
    echo "Installing $PACKAGE_NAME on Arch-based system..."
    
    sudo pacman -S --noconfirm neovim python-pynvim
    
    # Install dependencies for plugins
    sudo pacman -S --noconfirm git ripgrep fd
}

# Install Neovim on SUSE-based systems
install_suse() {
    echo "Installing $PACKAGE_NAME on SUSE-based system..."
    
    sudo zypper install -y neovim python3-neovim
    
    # Install dependencies for plugins
    sudo zypper install -y git ripgrep python3-pip
    sudo pip3 install pynvim
}

# Generic installation function for unsupported distributions
install_generic() {
    echo "Installing $PACKAGE_NAME on unsupported distribution..."
    echo "Attempting generic installation method using AppImage..."
    
    # Install via AppImage
    mkdir -p $HOME/.local/bin
    curl -Lo $HOME/.local/bin/nvim https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
    chmod u+x $HOME/.local/bin/nvim
    
    # Add to PATH if not already there
    if ! echo $PATH | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    echo "Please make sure to install git, ripgrep and other dependencies for plugins manually."
}

# Setup basic configuration files
setup_basic_config() {
    echo "Setting up basic Neovim configuration..."
    
    # Create config directory
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Create init.vim file
    cat > "$PACKAGE_DOTFILES_DIR/init.vim" << 'EOF'
" Basic Neovim Configuration

" General settings
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set tabstop=4           " Number of spaces tabs count for
set softtabstop=4       " Number of spaces for a tab while editing
set shiftwidth=4        " Number of spaces to use for autoindent
set expandtab           " Convert tabs to spaces
set smartindent         " Smart autoindent when starting a new line
set ruler               " Show the cursor position all the time
set hlsearch            " Highlight search results
set incsearch           " Incremental search
set ignorecase          " Case insensitive search
set smartcase           " Override ignorecase for uppercase
set nowrap              " Don't wrap lines
set clipboard+=unnamedplus " Use system clipboard
set cursorline          " Highlight current line
set mouse=a             " Enable mouse for all modes
set termguicolors       " Use true colors
set splitbelow          " Open new splits below
set splitright          " Open new splits to the right
set hidden              " Allow buffers to be hidden without saving
set backup              " Enable backups
set backupdir=~/.local/share/nvim/backup// " Backup directory
set undofile            " Persistent undo history
set undodir=~/.local/share/nvim/undo//     " Undo directory
set directory=~/.local/share/nvim/swap//   " Swap directory
set showmatch           " Show matching brackets
set visualbell          " No sounds
set colorcolumn=80      " Highlight column 80
set scrolloff=5         " Keep 5 lines visible when scrolling
set encoding=utf-8      " Use UTF-8 encoding

" Define mapleader for custom mappings
let mapleader = " "

" Key mappings
" Make j and k navigate visual lines rather than logical ones
nnoremap j gj
nnoremap k gk

" Quickly save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" Quickly clear search highlighting
nnoremap <leader><space> :noh<CR>

" Navigate between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" File explorer
nnoremap <leader>e :Explore<CR>

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" Terminal mode mappings
tnoremap <Esc> <C-\><C-n>
" Open terminal in split
nnoremap <leader>t :split<CR>:terminal<CR>i

" Automatically install vim-plug and plugins
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin management with vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Color scheme
Plug 'arcticicestudio/nord-vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" File explorer
Plug 'preservim/nerdtree'

" File finding
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Auto-completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Syntax highlighting
Plug 'sheerun/vim-polyglot'

" Comment handling
Plug 'tpope/vim-commentary'

" Surround text
Plug 'tpope/vim-surround'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

call plug#end()

" Plugin configuration
" NERDTree settings
nnoremap <leader>n :NERDTreeToggle<CR>

" FZF settings
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline_theme = 'nord'

" Colorscheme
colorscheme nord

" COC settings
" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)
EOF
    
    # Create directories for backup, undo, and swap files
    mkdir -p $HOME/.local/share/nvim/{backup,undo,swap}
    
    echo "Basic Neovim configuration created at $PACKAGE_DOTFILES_DIR/init.vim"
}

# Setup configuration files
setup_config() {
    echo "Setting up configuration for $PACKAGE_NAME..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$PACKAGE_DOTFILES_DIR"
    
    # Backup existing configuration
    if [ -f "$PACKAGE_DOTFILES_DIR/init.vim" ] || [ -f "$PACKAGE_DOTFILES_DIR/init.lua" ]; then
        echo "Backing up existing Neovim configuration..."
        backup_dir="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$PACKAGE_DOTFILES_DIR"/* "$backup_dir"
        echo "Backup created at $backup_dir"
    fi
    
    # Ask for configuration preference
    echo "Select Neovim configuration type:"
    echo "1. Basic Vim-like configuration (init.vim)"
    echo "2. No configuration (I'll set it up myself)"
    read -p "Choice [1-2]: " config_choice
    
    case $config_choice in
        1)
            setup_basic_config
            ;;
        2)
            echo "No configuration set up. You can configure Neovim by editing $PACKAGE_DOTFILES_DIR/init.vim or $PACKAGE_DOTFILES_DIR/init.lua"
            mkdir -p "$PACKAGE_DOTFILES_DIR"
            ;;
        *)
            echo "Invalid choice. Setting up basic configuration."
            setup_basic_config
            ;;
    esac
    
    echo "Configuration setup complete!"
}

# Main installation function
install_package() {
    echo "Installing $PACKAGE_NAME..."
    
    if is_installed; then
        current_version=$(nvim --version | head -n 1 | cut -d ' ' -f 2)
        echo "$PACKAGE_NAME is already installed (version $current_version)."
        read -p "Do you want to reinstall it? (y/N): " choice
        if [[ ! $choice =~ ^[Yy]$ ]]; then
            echo "Skipping installation."
            read -p "Do you want to set up/update the configuration? (y/N): " config_choice
            if [[ $config_choice =~ ^[Yy]$ ]]; then
                setup_config
            fi
            return
        fi
    fi
    
    # Install based on distribution family
    case $DISTRO_FAMILY in
        debian)
            install_debian
            ;;
        redhat)
            install_redhat
            ;;
        arch)
            install_arch
            ;;
        suse)
            install_suse
            ;;
        *)
            install_generic
            ;;
    esac
    
    if is_installed; then
        echo "$PACKAGE_NAME has been successfully installed!"
        new_version=$(nvim --version | head -n 1 | cut -d ' ' -f 2)
        echo "Version: $new_version"
        
        # Ask to set up configuration
        read -p "Do you want to set up Neovim configuration? (Y/n): " config_choice
        if [[ ! $config_choice =~ ^[Nn]$ ]]; then
            setup_config
        fi
    else
        echo "Failed to install $PACKAGE_NAME."
        exit 1
    fi
}

# Uninstall package
uninstall_package() {
    echo "Uninstalling $PACKAGE_NAME..."
    
    if ! is_installed; then
        echo "$PACKAGE_NAME is not installed."
        return
    fi
    
    # Ask to remove Neovim
    read -p "Are you sure you want to remove Neovim? (y/N): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        # Check if installed via package manager or manual method
        nvim_path=$(which nvim)
        
        if [[ "$nvim_path" == "/usr/bin/nvim" ]]; then
            # Installed via package manager
            case $DISTRO_FAMILY in
                debian)
                    sudo apt remove -y neovim python3-neovim
                    ;;
                redhat)
                    sudo dnf remove -y neovim python3-neovim
                    ;;
                arch)
                    sudo pacman -Rs --noconfirm neovim python-pynvim
                    ;;
                suse)
                    sudo zypper remove -y neovim python3-neovim
                    ;;
                *)
                    echo "Unsupported distribution for automatic uninstallation."
                    echo "Please uninstall Neovim manually."
                    ;;
            esac
        elif [[ "$nvim_path" == "/usr/local/bin/nvim" ]]; then
            # Likely installed from binary package
            sudo rm -f /usr/local/bin/nvim
            sudo rm -rf /opt/nvim
        elif [[ "$nvim_path" == "$HOME/.local/bin/nvim" ]]; then
            # Likely installed as AppImage
            rm -f "$HOME/.local/bin/nvim"
        else
            echo "Unknown installation method. Trying common uninstallation methods..."
            # Try to remove from common locations
            sudo rm -f /usr/bin/nvim /usr/local/bin/nvim "$HOME/.local/bin/nvim"
            sudo rm -rf /opt/nvim
        fi
        
        # Ask to remove configuration files
        read -p "Do you want to remove Neovim configuration files? (y/N): " config_choice
        if [[ $config_choice =~ ^[Yy]$ ]]; then
            echo "Backing up configuration before removal..."
            backup_dir="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"
            if [ -d "$PACKAGE_DOTFILES_DIR" ]; then
                mkdir -p "$backup_dir"
                cp -r "$PACKAGE_DOTFILES_DIR"/* "$backup_dir" 2>/dev/null || true
            fi
            
            # Remove Neovim configuration directory
            rm -rf "$PACKAGE_DOTFILES_DIR"
            
            # Remove plugin data
            rm -rf "$HOME/.local/share/nvim"
            
            echo "Neovim configuration has been removed. Backup created at $backup_dir"
        fi
        
        echo "$PACKAGE_NAME has been uninstalled."
    else
        echo "Uninstallation cancelled."
    fi
}

# Parse command line arguments
if [ "$1" == "uninstall" ]; then
    detect_distro
    uninstall_package
else
    detect_distro
    install_package
fi 