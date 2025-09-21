#!/bin/bash

# Debian 12 Dotfiles Setup Script with Profile Selection
# Run this script from your ~/.dotfiles directory

DOTFILES_DIR=$HOME/.dotfiles
SYMLINKS=(
    "i3:$HOME/.config/i3"
    "nvim:$HOME/.config/nvim"
    "kitty:$HOME/.config/kitty"
    "alacritty:$HOME/.config/alacritty"
    "tmux:$HOME/.config/tmux"
    "yazi:$HOME/.config/yazi"
    "vimrc:$HOME/.vimrc"
    "vim:$HOME/.vim"
    ".tmux.conf:$HOME/.tmux.conf"
    ".zshrc:$HOME/.zshrc"
    ".luarc.json:$HOME/.luarc.json"
    "scripts:$HOME/scripts"
    "rofi:$HOME/.config/rofi"
    ".xprofile:$HOME/.xprofile"
    ".themes:$HOME/.themes"
    "gtk-3.0:$HOME/.config/gtk-3.0"
    "wallpaper:$HOME/wallpaper"
    "mutt:$HOME/.config/mutt"
    "feh:$HOME/.config/feh"
    "i3/rofi-calculator.desktop:$HOME/.local/share/applications/rofi-calculator.desktop"
    "systemd/user/protonmail-bridge.service:$HOME/.config/systemd/user/protonmail-bridge.service"
    "conky:$HOME/.config/conky"
  )

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

# ============================================================================
# IMPORTANT GUARDS
# ============================================================================

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


# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to create symlinks
create_symlinks() {
  log_info "Creating symlinks for configuration files..."

  # Create .local/bin directory if it doesn't exist
  mkdir -p "$HOME/.local/bin"

  # Define config mappings: source_path:target_path
  local configs=$SYMLINKS
  # Add i3 config if i3 is being installed
  if [ "$INSTALL_I3" = true ]; then
    configs+=("i3:$HOME/.config/i3")
  fi

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
    ln -sf "$source_path" "$target"
    log_success "Symlink created for $source"
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
  log_info "TPM installed to $tmp_dir"
  log_warning "After tmux configuration is set up, press prefix + I to install plugins"
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

# Function to setup i3 window manager
setup_i3wm() {
  if [ "$INSTALL_I3" != true ]; then
    log_info "i3 setup skipped (not enabled in profile)"
    return
  fi

  log_info "Configuring i3 window manager..."

  # Set default target to graphical
  sudo systemctl set-default graphical.target
  log_success "Set default boot target to graphical (GUI)"

  # Enable and configure lightdm
  sudo systemctl enable lightdm

  # Create lightdm config to auto-start i3
  sudo mkdir -p /etc/lightdm/lightdm.conf.d
  sudo tee /etc/lightdm/lightdm.conf.d/10-i3.conf > /dev/null <<EOF
[Seat:*]
autologin-user=$USER
autologin-session=i3
EOF

# Create i3 session file if it doesn't exist
if [ ! -f "/usr/share/xsessions/i3.desktop" ]; then
  sudo tee /usr/share/xsessions/i3.desktop > /dev/null <<EOF
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
EOF
fi

log_success "i3 window manager configured"
log_info "System will boot into i3 automatically after reboot"
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
  log_info "Starting Debian 12 dotfiles minimal setup"

  # Setup sudo
  setup_sudo

  # install packages
  ./scripts/install-package-list.sh setup-scripts/packages/base.pk setup-scripts/packages/i3.pk

  # setup i3
  setup_i3wm

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

  log_success "Setup completed successfully with profile: $PROFILE"
  echo ""
  log_warning "IMPORTANT NEXT STEPS:"

  log_warning "Reboot to start using i3 window manager"
  log_info "After reboot, the system will automatically log in and start i3"
}

# Run main function
main "$@"
