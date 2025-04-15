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
            current_target=$(readlink -f "$dest" 2>/dev/null || readlink "$dest" 2>/dev/null || greadlink -f "$dest" 2>/dev/null)
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

# Check if Homebrew is installed, install if not
if ! command_exists brew; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon (M1/M2/M3) or Intel Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    log "Homebrew is already installed"
fi

# Install essential packages with Homebrew
log "Installing essential packages..."
brew update
brew install git curl wget zsh tmux vim neovim python3 fzf figlet zoxide kitty

# Install casks
log "Installing cask applications..."
brew install --cask alacritty

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log "Oh My Zsh is already installed"
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

# Tmux setup with clean TPM installation
log "Setting up Tmux..."
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Fix TPM installation
log "Setting up Tmux Plugin Manager (TPM)..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log "Removing existing TPM installation..."
    rm -rf "$HOME/.tmux/plugins/tpm"
fi

mkdir -p "$HOME/.tmux/plugins"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
log "TPM installed successfully"

# Setup kitty
log "Setting up kitty..."
mkdir -p "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"

# Setup alacritty
log "Setting up alacritty..."
mkdir -p "$HOME/.config/alacritty"
create_symlink "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"

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

# Make ZSH the default shell if it's not already
if [ "$SHELL" != "$(which zsh)" ]; then
    log "Making ZSH the default shell..."
    chsh -s "$(which zsh)"
else
    log "ZSH is already the default shell"
fi

# Install Lazygit (since it's in your aliases)
if ! command_exists lazygit; then
    log "Installing Lazygit..."
    brew install lazygit
fi

# Install TLDR for your help alias
if ! command_exists tldr; then
    log "Installing TLDR..."
    brew install tldr || pip3 install tldr
fi

# macOS-specific settings
log "Applying macOS-specific settings..."

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Faster key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Enable tap to click for trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Restart affected applications
for app in "Finder" "Dock" "SystemUIServer"; do
    killall "${app}" &> /dev/null
done

# Final message
log "macOS setup complete! 🚀"
log "Some changes may require a logout/restart to take effect."
log "After restarting, launch tmux and press prefix + I (capital i) to install tmux plugins."
