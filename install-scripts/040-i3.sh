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

# Optional: scripts to make executable
declare -ra EXECUTABLE_SCRIPTS=(
  "$HOME/.config/i3blocks/scripts/volume.sh"
  "$HOME/.config/scripts/start-conky.sh"
)

#################################
# Package Management
#################################

# Check if a package is installed
is_package_installed() {
  local package="$1"
  dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "^install ok installed$"
}

# Install a single package
install_package() {
  local package="$1"
  
  if is_package_installed "$package"; then
    log_success "$package is already installed"
    return 0
  fi
  
  log_info "Installing $package..."
  
  if [[ -x "$HOME/.dotfiles/install-scripts/install.sh" ]]; then
    "$HOME/.dotfiles/install-scripts/install.sh" "$package"
  else
    sudo apt-get install -y "$package"
  fi
  
  if is_package_installed "$package"; then
    log_success "$package installed successfully"
    return 0
  else
    log_error "Failed to install $package"
    return 1
  fi
}

# Install all system packages
install_system_packages() {
  if [[ ${#SYSTEM_PACKAGES[@]} -eq 0 ]]; then
    log_info "No system packages to install"
    return 0
  fi

  log_info "Installing ${#SYSTEM_PACKAGES[@]} system packages..."
  
  # Update package list first
  log_info "Updating package lists..."
  sudo apt-get update -qq || log_warning "Failed to update package lists"
  
  local failed_packages=()
  
  for package in "${SYSTEM_PACKAGES[@]}"; do
    if ! install_package "$package"; then
      failed_packages+=("$package")
    fi
  done
  
  if [[ ${#failed_packages[@]} -gt 0 ]]; then
    log_error "Failed to install the following packages:"
    printf '%s\n' "${failed_packages[@]}" | sed 's/^/  - /'
    return 1
  fi
  
  log_success "All packages installed successfully"
  return 0
}

#################################
# Symlink Management
#################################

# Backup existing file/directory
backup_existing() {
  local target="$1"
  local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
  
  log_info "Backing up $target to $backup"
  mv "$target" "$backup"
  log_success "Backup created: $backup"
}

# Create a single symlink
create_symlink() {
  local source_rel="$1"
  local target="$2"
  local source_path="$DOTFILES_DIR/$source_rel"
  
  # Check if source exists
  if [[ ! -e "$source_path" ]]; then
    log_warning "Source does not exist: $source_path (skipping)"
    return 1
  fi
  
  # Create target directory if needed
  local target_dir
  target_dir=$(dirname "$target")
  if [[ ! -d "$target_dir" ]]; then
    log_info "Creating directory: $target_dir"
    mkdir -p "$target_dir"
  fi
  
  # Handle existing target
  if [[ -e "$target" || -L "$target" ]]; then
    # Check if it's already the correct symlink
    if [[ -L "$target" && "$(readlink "$target")" == "$source_path" ]]; then
      log_success "Symlink already correct: $target → $source_path"
      return 0
    fi
    
    # Backup or remove existing
    log_warning "Target already exists: $target"
    read -rp "$(echo -e "${YELLOW}Backup and replace? [Y/n]:${NC} ")" -n 1 response
    echo
    
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
      if [[ -L "$target" ]]; then
        rm "$target"
      else
        backup_existing "$target"
      fi
    else
      log_warning "Skipping: $target"
      return 1
    fi
  fi
  
  # Create symlink
  log_info "Creating symlink: $target → $source_path"
  ln -sf "$source_path" "$target"
  
  if [[ -L "$target" && "$(readlink "$target")" == "$source_path" ]]; then
    log_success "Symlink created: $target"
    return 0
  else
    log_error "Failed to create symlink: $target"
    return 1
  fi
}

# Create all symlinks
create_symlinks() {
  if [[ ${#SYMLINKS[@]} -eq 0 ]]; then
    log_info "No symlinks to create"
    return 0
  fi

  log_info "Creating ${#SYMLINKS[@]} symlinks..."
  
  local failed_symlinks=()
  
  for config in "${SYMLINKS[@]}"; do
    IFS=':' read -r source target <<< "$config"
    
    if ! create_symlink "$source" "$target"; then
      failed_symlinks+=("$config")
    fi
  done
  
  if [[ ${#failed_symlinks[@]} -gt 0 ]]; then
    log_warning "Failed to create ${#failed_symlinks[@]} symlink(s)"
    return 1
  fi
  
  log_success "All symlinks created successfully"
  return 0
}

#################################
# Script Permissions
#################################

# Make scripts executable
make_scripts_executable() {
  if [[ ${#EXECUTABLE_SCRIPTS[@]} -eq 0 ]]; then
    return 0
  fi
  
  log_info "Making scripts executable..."
  
  for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
      chmod +x "$script"
      log_success "Made executable: $script"
    else
      log_warning "Script not found: $script"
    fi
  done
}

#################################
# Post-Installation
#################################

post_install_tasks() {
  log_info "Running post-installation tasks..."
  
  # Create necessary directories
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share/applications"
  mkdir -p "$HOME/Pictures/Screenshots"
  
  # Make scripts executable
  make_scripts_executable
  
  # Set wallpaper directory permissions
  if [[ -d "$HOME/wallpaper" ]]; then
    chmod -R 755 "$HOME/wallpaper"
  fi
  
  log_success "Post-installation tasks completed"
}

#################################
# Main Function
#################################

main() {
  local start_time
  start_time=$(date +%s)
  
  log_info "Starting i3 installation..."
  log_info "Dotfiles directory: $DOTFILES_DIR"
  
  # Verify dotfiles directory exists
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi
  
  # Install packages
  if ! install_system_packages; then
    log_error "Package installation failed"
    exit 1
  fi
  
  # Create symlinks (non-fatal)
  create_symlinks || log_warning "Some symlinks failed to create"
  
  # Post-installation tasks
  post_install_tasks
  
  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))
  
  echo
  log_success "i3 installation completed in ${duration}s"
  log_info "Next steps:"
  echo "  1. Log out and select i3 from your display manager"
  echo "  2. Press Super+Return to open a terminal"
  echo "  3. Press Super+r to launch rofi"
  echo "  4. Review the configuration in ~/.config/i3/config"
  echo
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
