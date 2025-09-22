#!/bin/bash

DOTFILES_DIR=$(./get-dotfiles-dir.sh)

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

APT_PACKAGES=(
    hyprland
    wofi
    waybar
    fonts-font-awesome
    wl-clipboard
  )

BREW_PACKAGES=()

# "i3:$HOME/.config/i3"
SYMLINKS=(
    "hypr:$HOME/.config/hypr"
    "waybar:$HOME/.config/waybar"
  )

# Function to install packages via apt
install_apt_packages() {
  if [ ${#APT_PACKAGES[@]} -eq 0 ]; then
    log_info "No APT packages to install"
    return
  fi

  log_info "Installing ${#APT_PACKAGES[@]} APT packages..."

    sudo apt update

    for package in "${APT_PACKAGES[@]}"; do
      if dpkg -l | grep -q "^ii  $package "; then
        log_success "$package is already installed"
      else
        log_info "Installing $package..."
        sudo apt install -y "$package"
        log_success "$package installed"
      fi
    done
  }

# Function to install packages via Homebrew
install_brew_packages() {
  if [ ${#BREW_PACKAGES[@]} -eq 0 ]; then
    log_info "No brew packages to install"
    return
  fi

  log_info "Installing ${#BREW_PACKAGES[@]} Homebrew packages..."

  # Ensure brew is in PATH
  if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  for package in "${BREW_PACKAGES[@]}"; do
    if brew list "$package" >/dev/null 2>&1; then
      log_success "$package is already installed via brew"
    else
      log_info "Installing $package via brew..."
      yes  | brew install "$package"
      log_success "$package installed via brew"
    fi
  done
}

# Function to create symlinks
create_symlinks() {
  log_info "Creating symlinks..."

  # Create .local/bin directory if it doesn't exist
  mkdir -p "$HOME/.local/bin"

  # Check if SYMLINKS array is empty or unset
  if [ ${#SYMLINKS[@]} -eq 0 ]; then
    log_info "No symlinks to create (SYMLINKS array is empty)"
    return 0
  fi

  for config in "${SYMLINKS[@]}"; do
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

deb_sid_instructions() {
  # Check if already on Debian sid main
  if grep -q "deb.*sid main" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    log_success "Debian sid main repository is already configured"
    return 0
  fi
  
  # Check if we're on Debian (not Ubuntu or other distros)
  if ! grep -q "^ID=debian" /etc/os-release 2>/dev/null; then
    log_warning "This system doesn't appear to be Debian. Skipping sid repository setup."
    return 0
  fi
  
  # Warn user about sid (unstable)
  log_warning "Debian sid (unstable) repository is not currently configured."
  log_warning "Debian sid is the unstable branch and may contain broken packages."
  log_warning "Only proceed if you understand the risks and have researched Debian sid."
  
  # Ask for user confirmation
  echo -n "Do you want to enable Debian sid main repository? (y/N): "
  read -r response
  
  case "$response" in
    [yY]|[yY][eE][sS])
      log_info "Adding Debian sid main repository..."
      
      # Backup current sources.list
      if [ -f /etc/apt/sources.list ]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)
        log_info "Backed up /etc/apt/sources.list"
      fi
      
      # Add sid repository
      echo "deb http://deb.debian.org/debian sid main" | sudo tee -a /etc/apt/sources.list
      log_success "Added Debian sid main repository to sources.list"
      
      # Update package lists
      log_info "Updating package lists..."
      sudo sudo apt update
      log_success "Package lists updated"
      ;;
    *)
      log_info "Debian sid repository setup skipped by user"
      ;;
  esac
}

main() {
  deb_sid_instructions

  install_apt_packages
  install_brew_packages
  create_symlinks
}

main
