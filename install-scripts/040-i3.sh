#!/usr/bin/env bash
#
# i3 Window Manager Installation Script
# Installs i3 and related packages, creates necessary symlinks
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Better word splitting

# Get dotfiles directory
DOTFILES_DIR=$(./get-dotfiles-dir.sh 2>/dev/null || echo "$HOME/.dotfiles")

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

#################################
# Logging Functions
#################################

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

#################################
# Configuration
#################################

# System packages to install
declare -ra SYSTEM_PACKAGES=(
  i3
  i3blocks
  i3status
  i3lock
  dmenu
  rofi
  nitrogen
  scrot
  xorg
  picom
  kitty
  dunst
  brightnessctl
  playerctl
  pavucontrol
  network-manager-gnome
  nemo
  feh
)

# Symlinks: source:target format
declare -ra SYMLINKS=(
  "i3:$HOME/.config/i3"
  "i3blocks:$HOME/.config/i3blocks"
  "rofi:$HOME/.config/rofi"
  "picom:$HOME/.config/picom"
  ".xprofile:$HOME/.xprofile"
  ".Xresources:$HOME/.Xresources"
  ".themes:$HOME/.themes"
  "gtk-3.0:$HOME/.config/gtk-3.0"
  "wallpaper:$HOME/wallpaper"
  "dunst:$HOME/.config/dunst"
  "i3/rofi-calculator.desktop:$HOME/.local/share/applications/rofi-calculator.desktop"
)

# Function to install packages via system
install_system_packages() {
  if [ ${#SYSTEM_PACKAGES[@]} -eq 0 ]; then
    log_info "No system packages to install"
    return
  fi

  log_info "Installing ${#SYSTEM_PACKAGES[@]} APT packages..."


    for package in "${system_PACKAGES[@]}"; do
      log_info "Installing $package..."
      ~/.dotfiles/install-scripts/install.sh "$package"
      log_success "$package installed"
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

main() {
  install_system_packages
  create_symlinks
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
