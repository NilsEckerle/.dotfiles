#!/bin/bash

# Debian 12 Dotfiles Setup Script
# Run this script from your ~/.dotfiles directory

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "This script should NOT be run as root!"
    log_error "It will install dotfiles in the wrong location (/root instead of your user home)"
    log_error ""
    log_error "If your user is not in sudo group, run this as root first:"
    log_error "  usermod -aG sudo your-username"
    log_error ""
    log_error "Then log out/in and run this script as your regular user."
    exit 1
fi

# Check if user has sudo privileges
if ! groups "$USER" | grep -q '\bsudo\b'; then
    log_error "User $USER is not in sudo group. Please run as root first:"
    log_error "  usermod -aG sudo $USER"
    log_error "  echo \"$USER ALL=(ALL:ALL) ALL\" >> /etc/sudoers.d/$USER"
    log_error "Then log out/in and run this script as $USER"
    exit 1
fi

# Check if script is run from dotfiles directory
if [ ! -f "README.md" ] || [ ! -d "nvim" ] || [ ! -d "setup-scripts" ]; then
    log_error "Please run this script from your ~/.dotfiles directory"
    exit 1
fi

DOTFILES_DIR=$(pwd)
log_info "Dotfiles directory: $DOTFILES_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages via apt
install_apt_packages() {
    log_info "Updating package list..."
    sudo apt update

    local packages=(
        "sudo"
        "zsh" 
        "tmux"
        "kitty"
        "vim"
        "ripgrep"
        "curl"
        "wget"
        "git"
        "build-essential"
        "procps"
        "file"
        "openssh-server"
        "figlet"
        "fzf"
        "tldr"
        "python3"
        "python3-pip"
        "python3-venv"
        "yarnpkg"
    )

    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log_success "$package is already installed"
        else
            log_info "Installing $package..."
            sudo apt install -y "$package"
            log_success "$package installed"
        fi
    done
    
    # Copy scripts to .local/bin and make them executable (including subdirectories)
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        log_info "Copying scripts to $HOME/.local/bin..."
        find "$DOTFILES_DIR/scripts" -type f -executable -exec cp {} "$HOME/.local/bin/" \;
        find "$DOTFILES_DIR/scripts" -name "*.sh" -exec cp {} "$HOME/.local/bin/" \;
        chmod +x "$HOME/.local/bin"/*
        log_success "Scripts copied and made executable"
    fi
}

# Function to install Homebrew
install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew is already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
}

# Function to install packages via Homebrew
install_brew_packages() {
    log_info "Installing packages via Homebrew..."
    
    # Ensure brew is in PATH
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    local packages=(
        "neovim"
        "zoxide"
    )

    for package in "${packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_success "$package is already installed via brew"
        else
            log_info "Installing $package via brew..."
            brew install "$package"
            log_success "$package installed via brew"
        fi
    done
}

# Function to install TPM (Tmux Plugin Manager)
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [ -d "$tpm_dir" ]; then
        log_success "TPM (Tmux Plugin Manager) is already installed"
        return
    fi
    
    log_info "Installing TPM (Tmux Plugin Manager)..."
    
    # Create tmux plugins directory
    mkdir -p "$HOME/.tmux/plugins"
    
    # Clone TPM repository
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    
    log_success "TPM installed"
    log_info "TPM installed to $tpm_dir"
    log_warning "After tmux configuration is set up, press prefix + I to install plugins"
}

# Function to create symlinks
create_symlinks() {
    log_info "Creating symlinks for configuration files..."
    
    # Create .local/bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Define config mappings: source_path:target_path
    local configs=(
        "nvim:$HOME/.config/nvim"
        "kitty:$HOME/.config/kitty"
        "alacritty:$HOME/.config/alacritty"
        "i3:$HOME/.config/i3"
        "tmux:$HOME/.config/tmux"
        "yazi:$HOME/.config/yazi"
        "vimrc:$HOME/.vimrc"
        "vim:$HOME/.vim"
				".tmux.conf:$HOME/.tmux.conf"
				".zshrc:$HOME/.zshrc"
				".luarc.json:$HOME/.luarc.json"
    )

    for config in "${configs[@]}"; do
        IFS=':' read -r source target <<< "$config"
        source_path="$DOTFILES_DIR/$source"
        
        # Skip if source doesn't exist
        if [ ! -e "$source_path" ]; then
            log_warning "Source $source_path does not exist, skipping..."
            continue
        fi
        
        # Create target directory if it doesn't exist
        target_dir=$(dirname "$target")
        if [ ! -d "$target_dir" ]; then
            log_info "Creating directory $target_dir"
            mkdir -p "$target_dir"
        fi
        
        # Remove existing target if it exists and is not a symlink to our source
        if [ -e "$target" ]; then
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_path" ]; then
                log_success "Symlink for $source already exists and is correct"
                continue
            else
                log_warning "Removing existing $target"
                rm -rf "$target"
            fi
        fi
        
        # Create symlink
        log_info "Creating symlink: $target -> $source_path"
        ln -s "$source_path" "$target"
        log_success "Symlink created for $source"
    done
}

# Function to setup Zsh as default shell
setup_zsh() {
    if [ "$SHELL" = "$(which zsh)" ]; then
        log_success "Zsh is already the default shell"
        return
    fi
    
    log_info "Setting up Zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Zsh set as default shell (will take effect on next login)"
}

# Function to setup SSH for key-only authentication
setup_ssh() {
    log_info "Configuring SSH for key-only authentication..."
    
    # Enable and start SSH service
    sudo systemctl enable ssh
    sudo systemctl start ssh
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Backup original SSH config
    if [ -f "/etc/ssh/sshd_config" ]; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        log_info "SSH config backed up to /etc/ssh/sshd_config.backup"
    fi
    
		# Configure SSH daemon for key-only authentication
		sudo tee /etc/ssh/sshd_config.d/99-custom.conf > /dev/null <<EOF
# Custom SSH configuration for key-only authentication
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
EOF
    
    # Test SSH configuration
    if sudo sshd -t; then
        sudo systemctl restart ssh
        log_success "SSH configured for key-only authentication"
        log_warning "Remember to add your SSH public key to ~/.ssh/authorized_keys before logging out!"
    else
        log_error "SSH configuration test failed. Please check the configuration."
        return 1
    fi
}

# Function to setup sudo
setup_sudo() {
    log_info "Configuring sudo..."
    
    # Add current user to sudo group if not already there
    if groups "$USER" | grep -q '\bsudo\b'; then
        log_success "User $USER is already in sudo group"
    else
        log_info "Adding user $USER to sudo group..."
        sudo usermod -aG sudo "$USER"
        log_success "User $USER added to sudo group"
        log_warning "You may need to log out and back in for sudo group membership to take effect"
    fi
    
    # Configure sudo to not require password for a short time after first use
    if [ ! -f "/etc/sudoers.d/timestamp_timeout" ]; then
        echo "Defaults timestamp_timeout=15" | sudo tee /etc/sudoers.d/timestamp_timeout > /dev/null
        log_success "Sudo timeout configured (15 minutes)"
    fi
}

# Function to disable desktop environment and configure TTY boot
setup_headless_boot() {
    log_info "Configuring system for headless/TTY boot..."
    
    # Set default target to multi-user (console) instead of graphical
    sudo systemctl set-default multi-user.target
    log_success "Set default boot target to multi-user (TTY)"
    
    # Disable common display managers
    for dm in gdm3 lightdm sddm xdm; do
        if systemctl is-enabled "$dm" >/dev/null 2>&1; then
            sudo systemctl disable "$dm"
            log_success "Disabled display manager: $dm"
        fi
    done
    
    # Disable screen blanking/sleep on TTY
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    log_success "Disabled sleep/suspend/hibernate targets"
    
    # Disable console screen blanking via GRUB
    if grep -q "consoleblank=0" /etc/default/grub; then
        log_success "Console blanking already disabled in GRUB"
    else
        log_info "Disabling console screen blanking in GRUB..."
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet consoleblank=0"/' /etc/default/grub
        sudo update-grub
        log_success "Console screen blanking disabled in GRUB"
    fi
    
    log_info "System configured for TTY boot. Reboot to take effect."
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_success "Oh My Zsh is already installed"
        return
    fi
    
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed"
}

# Function to setup .zshrc
setup_zshrc() {
    log_info "Setting up .zshrc..."
    
    # If we have a .zshrc in dotfiles, use it
    if [ -f "$DOTFILES_DIR/.zshrc" ]; then
        log_info "Found .zshrc in dotfiles, creating symlink..."
        if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
            log_info "Backed up existing .zshrc to .zshrc.backup"
        fi
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc symlinked from dotfiles"
    else
        log_warning "No .zshrc found in dotfiles directory"
    fi
}

# Main execution
main() {
    log_info "Starting Debian 12 dotfiles setup..."
    
    # Install system packages
    install_apt_packages
    
    # Setup sudo
    setup_sudo
    
    # Configure headless/TTY boot
    # setup_headless_boot
    
    # Install Homebrew
    install_homebrew
    
    # Install Homebrew packages
    install_brew_packages
    
    # Install Oh My Zsh
    install_oh_my_zsh

    # Install TPM (Tmux Plugin Manager)
    install_tpm
    
    # Create symlinks
    create_symlinks
    
    # Setup .zshrc
    setup_zshrc
    
    # Setup Zsh as default shell
    setup_zsh
    
    # Setup SSH
    setup_ssh
    
    log_success "Setup completed successfully!"
    echo ""
    log_warning "IMPORTANT NEXT STEPS:"
    log_warning "1. Add your SSH public key to ~/.ssh/authorized_keys"
    log_warning "2. Test SSH connection before logging out"
    log_warning "3. Restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_warning "4. You may need to log out and back in for shell and group changes to take effect"
    echo ""
    log_info "SSH public key should be added with: echo 'your-public-key' >> ~/.ssh/authorized_keys"
    log_info "Then set proper permissions: chmod 600 ~/.ssh/authorized_keys"
}

# Run main function
main "$@"
