#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Please don't run as root. The script will use sudo when needed."
    exit 1
fi

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    PKG_UPDATE="sudo apt-get update"
    PKG_INSTALL="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="sudo dnf check-update"
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    PKG_UPDATE="sudo pacman -Sy"
    PKG_INSTALL="sudo pacman -S --noconfirm"
else
    error "Unsupported package manager. Please install packages manually."
    exit 1
fi

# Main dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to backup existing config if it exists
backup_if_exists() {
    if [ -e "$1" ]; then
        backup_path="$1.backup.$(date +%Y%m%d%H%M%S)"
        log "Backing up $1 to $backup_path"
        mv "$1" "$backup_path"
    fi
}

# Function to create symlinks
create_symlink() {
    src="$1"
    dest="$2"
    
    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
            current_target=$(readlink -f "$dest")
            if [ "$current_target" = "$src" ]; then
                info "Symlink $dest already points to $src"
                return
            fi
        fi
        backup_if_exists "$dest"
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    log "Created symlink: $dest -> $src"
}

# ---- Main Setup ----

# Update system
log "Updating system package lists..."
eval $PKG_UPDATE

# Install essential packages
log "Installing Linux essentials..."
$PKG_INSTALL git curl wget make gcc g++ build-essential figlet zsh tmux vim neovim python3 python3-pip python3-venv fzf

# Install Homebrew if not installed
if ! command_exists brew; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH (if not already in .zshrc)
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    log "Homebrew is already installed"
fi

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log "Oh My Zsh is already installed"
fi

# Install Zoxide
if ! command_exists zoxide; then
    log "Installing Zoxide..."
    $PKG_INSTALL zoxide || brew install zoxide
else
    log "Zoxide is already installed"
fi

# Install Yazi if not already installed
if ! command_exists yazi; then
    log "Installing Yazi file manager..."
    if command_exists cargo; then
        cargo install --locked yazi-fm
    else
        log "Installing Rust for Yazi..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        cargo install --locked yazi-fm
    fi
else
    log "Yazi is already installed"
fi

# Create symlinks for all dotfiles
log "Setting up symlinks..."

# ZSH
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Vim
create_symlink "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES_DIR/vim" "$HOME/.vim"

# Neovim
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux setup with fix for TPM
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/tmux" "$HOME/.tmux"

# Fix TPM installation
log "Setting up Tmux Plugin Manager (TPM)..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log "Removing existing TPM installation..."
    rm -rf "$HOME/.tmux/plugins/tpm"
fi

mkdir -p "$HOME/.tmux/plugins"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
log "TPM installed successfully"

# Setup i3 if available
if command_exists i3; then
    log "Setting up i3..."
    mkdir -p "$HOME/.config"
    create_symlink "$DOTFILES_DIR/i3" "$HOME/.config/i3"
fi

# Setup kitty if available
if command_exists kitty; then
    log "Setting up kitty..."
    create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
fi

# Setup alacritty if available
if command_exists alacritty; then
    log "Setting up alacritty..."
    create_symlink "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"
fi

# Setup Yazi
log "Setting up Yazi file manager..."
mkdir -p "$HOME/.config/yazi"
create_symlink "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"

# Setup scripts
log "Setting up scripts..."
create_symlink "$DOTFILES_DIR/scripts" "$HOME/scripts"
chmod +x "$HOME/scripts/"*.sh

# Setup wallpaper
log "Setting up wallpaper..."
create_symlink "$DOTFILES_DIR/wallpaper" "$HOME/wallpaper"

# Make ZSH the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    log "Making ZSH the default shell..."
    chsh -s "$(which zsh)"
else
    log "ZSH is already the default shell"
fi

# Install Lazygit (since it's in your aliases)
if ! command_exists lazygit; then
    log "Installing Lazygit..."
    brew install jesseduffield/lazygit/lazygit || \
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
fi

# Optional: Install TLDR for your help alias
if ! command_exists tldr; then
    log "Installing TLDR..."
    pip3 install tldr
fi

# Final message
log "Linux setup complete! 🚀"
log "Please log out and log back in for the shell change to take effect."
log "After logging back in, start tmux and press prefix + I (capital i) to install tmux plugins."
