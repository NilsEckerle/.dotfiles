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

system_PACKAGES=(
  keepassxc
  syncthing
)

SYMLINKS=(
  "services/syncthing@user.service:/etc/systemd/system/syncthing@$USER.service"
  )

# Function to install packages via system
install_system_packages() {
  if [ ${#system_PACKAGES[@]} -eq 0 ]; then
    log_info "No system packages to install"
    return
  fi

  log_info "Installing ${#system_PACKAGES[@]} APT packages..."

  log_info "Installing $package..."
  ~/.dotfiles/install-scripts/install.sh "$package"
  log_success "$package installed"
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
    sudo ln -sf "$source_path" "$target"
    log_success "Symlink created for $source"
  done
}

create_syncthing_service() {
  echo "
[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=4

[Service]
User=%i
Environment="STLOGFORMATTIMESTAMP="
Environment="STLOGFORMATLEVELSTRING=false"
Environment="STLOGFORMATLEVELSYSLOG=true"
ExecStart=/usr/bin/syncthing serve --no-browser --no-restart
Restart=on-failure
RestartSec=1
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

# Hardening
ProtectSystem=full
PrivateTmp=true
SystemCallArchitectures=native
MemoryDenyWriteExecute=true
NoNewPrivileges=true

# Elevated permissions to sync ownership (disabled by default),
# see https://docs.syncthing.net/advanced/folder-sync-ownership
#AmbientCapabilities=CAP_CHOWN CAP_FOWNER

[Install]
WantedBy=multi-user.target
  " > k
}

main() {
  install_system_packages
  create_symlinks
  create_syncthing_service
}

main
