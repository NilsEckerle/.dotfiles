#!/bin/bash

# Debian 12 Dotfiles Setup Script with Package File Selection
# Run this script from your ~/.dotfiles directory
# Usage: ./minimal-desktop.sh [package-files...]
# Example: ./minimal-desktop.sh base.txt i3.txt

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# CONFIGURATION
# ============================================================================

# Arrays to hold packages (will be populated from files)
APT_PACKAGES=()
BREW_PACKAGES=()

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

# Function to show usage
show_usage() {
  echo "Usage: $0 [package-files...]"
  echo ""
  echo "Available package files:"
  if [ -d "$PACKAGES_DIR" ]; then
    find "$PACKAGES_DIR" -name "*.pk" -type f | sed "s|$PACKAGES_DIR/||" | sort
  fi
  echo ""
  echo "Examples:"
  echo "  $0 packages/base.pk         # Install base packages only"
  echo "  $0 ./packages/base.pk ./packages/i3.pk   # Install base + i3 packages"
  echo "  $0 /home/user/Documents/minimal.pk      # Install minimal packages only"
}

# Function to read packages from file
read_package_file() {
  local file_path="$1"
  
  if [ ! -f "$file_path" ]; then
    log_warning "Package file not found: $file_path"
    return 1
  fi
  
  log_info "Reading packages from: $(basename "$file_path")"
  
  # Read file line by line, skip empty lines and comments
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments (lines starting with #)
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
      continue
    fi
    
    # Trim whitespace
    package_spec=$(echo "$line" | xargs)

    manager="${package_spec%/*}"  # Everything before the last /
    package="${package_spec##*/}" # Everything after the last /
    
    if [ -n "$package" ]; then
      # Add to the specified array
      if [ "$manager" = "apt" ]; then
        APT_PACKAGES+=("$package")
      elif [ "$manager" = "brew" ]; then
        BREW_PACKAGES+=("$package")
      fi
    fi
  done < "$file_path"
}

# Function to load packages based on specified files
load_packages() {
 local package_files=("$@")
 
 # Use default if no files specified
 if [ ${#package_files[@]} -eq 0 ]; then
   log_info "No package files specified. try --help."
   exit 1
 fi
 
 log_info "Loading packages from files: ${package_files[*]}"
 
 # Clear existing arrays
 APT_PACKAGES=()
 BREW_PACKAGES=()
 
 # Load packages from specified files
 for file in "${package_files[@]}"; do
   local file_path="$PWD/$file"

   # This is an APT package file
   read_package_file "$file_path"
 done
 
 # Remove duplicates
 APT_PACKAGES=($(printf '%s\n' "${APT_PACKAGES[@]}" | sort -u))
 BREW_PACKAGES=($(printf '%s\n' "${BREW_PACKAGES[@]}" | sort -u))
 
 log_success "Loaded ${#APT_PACKAGES[@]} APT packages and ${#BREW_PACKAGES[@]} brew packages"
 
 # Show what will be installed
 if [ ${#APT_PACKAGES[@]} -gt 0 ]; then
   log_info "APT packages to install: ${APT_PACKAGES[*]}"
 fi
 
 if [ ${#BREW_PACKAGES[@]} -gt 0 ]; then
   log_info "Brew packages to install: ${BREW_PACKAGES[*]}"
 fi
}

# Function to validate package files exist
validate_package_files() {
  local package_files=("$@")
  local missing_files=()
  
  for file in "${package_files[@]}"; do
    local file_path="$PWD/$file"
    if [ ! -f "$file_path" ]; then
      missing_files+=("$file")
    fi
  done
  
  if [ ${#missing_files[@]} -gt 0 ]; then
    log_error "The following package files were not found:"
    for file in "${missing_files[@]}"; do
      log_error "  - $file"
    done
    echo ""
    show_usage
    exit 1
  fi
}

# ============================================================================
# IMPORTANT GUARDS
# ============================================================================

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  log_error "This script should NOT be run as root!"
  log_error "It will install packages from a file and prompts sudo password if needed"
  log_error ""
  log_error "If your user is not in sudo group, run this as root first:"
  log_error "  usermod -aG sudo your-username"
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

DOTFILES_DIR=$(pwd)
log_info "Dotfiles directory: $DOTFILES_DIR"
log_info "Packages directory: $PACKAGES_DIR"

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install essential tools needed for setup
install_essential_tools() {
  log_info "Installing essential tools for setup..."

  # Update package list first
  sudo apt update

  # Define essential tools needed for the setup process
  local essential_tools=(
    "curl"
    "wget"
    "gnupg"
    "ca-certificates"
    "apt-transport-https"
  )

  # Install each essential tool if not already present
  for tool in "${essential_tools[@]}"; do
    if ! command_exists "$tool" && ! dpkg -l | grep -q "^ii  $tool "; then
      log_info "Installing essential tool: $tool"
      sudo apt install -y "$tool"
    else
      log_success "Essential tool already available: $tool"
    fi
  done

  log_success "Essential tools installation completed"
}

# Function to install packages via apt
install_apt_packages() {
  if [ ${#APT_PACKAGES[@]} -eq 0 ]; then
    log_info "No APT packages to install"
    return
  fi

  log_info "Installing ${#APT_PACKAGES[@]} APT packages..."

  sudo apt update
  # Install essential tools first (needed for adding custom sources)
  install_essential_tools

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

# Function to install Homebrew
install_homebrew() {
    if [ ${#BREW_PACKAGES[@]} -eq 0 ]; then
        log_info "No brew packages specified, skipping Homebrew installation"
        return
    fi

    if command_exists brew; then
        log_success "Homebrew is already installed"
        return
    fi

    log_info "Installing Homebrew..."
    yes  | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
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

# Main execution
main() {
  # Show help if requested
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
  fi

  # Parse command line arguments (package files)
  local package_files=("$@")
  
  # Validate package files exist
  if [ ${#package_files[@]} -gt 0 ]; then
    validate_package_files "${package_files[@]}"
  fi
  
  # Load packages from files
  load_packages "${package_files[@]}"
  
  # Confirm with user what will be installed
  echo ""
  log_info "About to install:"
  if [ ${#APT_PACKAGES[@]} -gt 0 ]; then
    log_info "APT packages (${#APT_PACKAGES[@]}): ${APT_PACKAGES[*]}"
  fi
  if [ ${#BREW_PACKAGES[@]} -gt 0 ]; then
    log_info "Brew packages (${#BREW_PACKAGES[@]}): ${BREW_PACKAGES[*]}"
  fi
  echo ""
  
  read -p "Continue with installation? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installation cancelled by user"
    exit 0
  fi

  # Install system packages
  install_apt_packages

  # Install Homebrew and packages (if any brew packages specified)
  install_homebrew
  install_brew_packages

  log_success "Installation completed successfully!"
  echo ""
  log_info "Package files used: ${package_files[*]:-${DEFAULT_PACKAGE_FILES[*]}}"
  log_info "Total packages installed: APT(${#APT_PACKAGES[@]}) + Brew(${#BREW_PACKAGES[@]})"
}

# Run main function
main "$@"
