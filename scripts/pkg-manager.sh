#!/usr/bin/env bash

# Package manager wrapper script
# Supports apt and brew with package lists and configuration tracking

CONFIG_FILE="$HOME/.config/pkg-manager/config"
PACKAGE_LISTS_DIR="$HOME/.config/pkg-manager/lists"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create necessary directories
mkdir -p "$(dirname "$CONFIG_FILE")"
mkdir -p "$PACKAGE_LISTS_DIR"

# Initialize config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "# Package Manager Configuration" > "$CONFIG_FILE"
  echo "# Format: manager/package" >> "$CONFIG_FILE"
fi

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

# Check if a package manager is available
check_manager() {
  local manager="$1"
  case "$manager" in
    "apt")
      command -v apt >/dev/null 2>&1 || { log_error "apt is not available on this system"; return 1; }
      ;;
    "brew")
      command -v brew >/dev/null 2>&1 || { log_error "brew is not available on this system"; return 1; }
      ;;
    *)
      log_error "Unsupported package manager: $manager"
      return 1
      ;;
  esac
}

# Install a single package
install_package() {
  local pkg_spec="$1"
  local manager
  local package

  if [[ "$pkg_spec" == *"/"* ]]; then
    manager="${pkg_spec%%/*}"
    package="${pkg_spec##*/}"
  else
    log_error "Invalid package specification: $pkg_spec (use manager/package format)"
    return 1
  fi

  check_manager "$manager" || return 1

  log_info "Installing $package using $manager..."

  case "$manager" in
    "apt")
      if sudo apt update && sudo apt install -y "$package"; then
        log_success "Installed $package with apt"
        add_to_config "$pkg_spec"
        return 0
      else
        log_error "Failed to install $package with apt"
        return 1
      fi
      ;;
    "brew")
      if brew install "$package"; then
        log_success "Installed $package with brew"
        add_to_config "$pkg_spec"
        return 0
      else
        log_error "Failed to install $package with brew"
        return 1
      fi
      ;;
  esac
}

# Remove a package (removes from all managers and config)
remove_package() {
  local package="$1"
  local removed=false

  log_info "Removing $package from all package managers..."

  # Try to remove from apt
  if command -v apt >/dev/null 2>&1; then
    if dpkg -l | grep -q "^ii.*$package "; then
      if sudo apt remove -y "$package"; then
        log_success "Removed $package with apt"
        removed=true
      fi
    fi
  fi

  # Try to remove from brew
  if command -v brew >/dev/null 2>&1; then
    if brew list | grep -q "^$package$"; then
      if brew uninstall "$package"; then
        log_success "Removed $package with brew"
        removed=true
      fi
    fi
  fi

  if [ "$removed" = true ]; then
    remove_from_config "$package"
  else
    log_warning "Package $package was not found in any package manager"
  fi
}

# Add package to configuration file
add_to_config() {
  local pkg_spec="$1"

  # Check if already in config
  if grep -Fxq "$pkg_spec" "$CONFIG_FILE"; then
    return 0
  fi

  echo "$pkg_spec" >> "$CONFIG_FILE"
  log_info "Added $pkg_spec to configuration"
}

# Remove package from configuration file
remove_from_config() {
  local package="$1"
  local temp_file=$(mktemp)

  # Remove lines containing the package name
  grep -v "/$package$" "$CONFIG_FILE" > "$temp_file"
  mv "$temp_file" "$CONFIG_FILE"
  log_info "Removed $package from configuration"
}

# Install from package list file
install_from_list() {
  local list_file="$1"
  local full_path

  # Check if it's a .pk file in current directory
  if [ -f "$list_file" ]; then
    full_path="$list_file"
    # Check if it's in the package lists directory
  elif [ -f "$PACKAGE_LISTS_DIR/$list_file" ]; then
    full_path="$PACKAGE_LISTS_DIR/$list_file"
  else
    log_error "Package list not found: $list_file"
    return 1
  fi

  log_info "Installing packages from $full_path..."

  local failed=0
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    line=$(echo "$line" | xargs)
    [[ -z "$line" ]] && continue

    if ! install_package "$line"; then
      ((failed++))
    fi
  done < "$full_path"

  if [ $failed -eq 0 ]; then
    log_success "All packages from $list_file installed successfully"
  else
    log_warning "$failed packages failed to install from $list_file"
  fi
}

# List installed packages
list_packages() {
  log_info "Packages in configuration:"

  if [ ! -s "$CONFIG_FILE" ]; then
    echo "No packages in configuration file"
    return 0
  fi

  # Group by package manager
  local apt_packages=""
  local brew_packages=""

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" == apt/* ]]; then
      apt_packages="$apt_packages ${line##*/}"
    elif [[ "$line" == brew/* ]]; then
      brew_packages="$brew_packages ${line##*/}"
    fi
  done < "$CONFIG_FILE"

  if [ -n "$apt_packages" ]; then
    echo -e "${GREEN}APT packages:${NC}$apt_packages"
  fi

  if [ -n "$brew_packages" ]; then
    echo -e "${GREEN}Brew packages:${NC}$brew_packages"
  fi
}

# Show usage information
usage() {
  echo "Usage: $0 <command> [arguments]"
  echo ""
  echo "Commands:"
  echo "  install <packages...>  Install packages or package lists"
  echo "  remove <package>       Remove a package"
  echo "  list                   List configured packages"
  echo ""
  echo "Package format: manager/package (e.g., apt/vim, brew/zoxide)"
  echo "Package lists: .pk files (e.g., i3.pk, base.pk)"
  echo ""
  echo "Examples:"
  echo "  $0 install apt/vim brew/zoxide"
  echo "  $0 install i3.pk base.pk"
  echo "  $0 remove vim"
  echo "  $0 list"
  echo ""
  echo "Configuration file: $CONFIG_FILE"
  echo "Package lists directory: $PACKAGE_LISTS_DIR"
}

# Main script logic
main() {
  if [ $# -eq 0 ]; then
    usage
    exit 1
  fi

  local command="$1"
  shift

  case "$command" in
    "install")
      if [ $# -eq 0 ]; then
        log_error "No packages specified for installation"
        exit 1
      fi

      for pkg in "$@"; do
        if [[ "$pkg" == *.pk ]]; then
          install_from_list "$pkg"
        else
          install_package "$pkg"
        fi
      done
      ;;
    "remove")
      if [ $# -eq 0 ]; then
        log_error "No package specified for removal"
        exit 1
      fi
      remove_package "$1"
      ;;
    "list")
      list_packages
      ;;
    "help"|"-h"|"--help")
      usage
      ;;
    *)
      log_error "Unknown command: $command"
      usage
      exit 1
      ;;
  esac
}

main "$@"
