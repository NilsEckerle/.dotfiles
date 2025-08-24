#!/bin/bash

# Debian package management.
# This tool can install and uninstall packages in apt and brew while
# saving the installed packages into a package file to automaticly
# install it on other systems.

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

# Function to show usage
show_usage() {
  echo "Usage: $0 {install/remove/list/config}"
  echo ""
  echo "Available package files:"
  if [ -d "$PACKAGES_DIR" ]; then
    find "$PACKAGES_DIR" -name "*.txt" -type f | sed "s|$PACKAGES_DIR/||" | sort
  fi
  echo ""
  echo "Examples:"
  echo "  $0                    # Install default packages (base.txt)"
  echo "  $0 base.txt          # Install base packages only"
  echo "  $0 base.txt i3.txt   # Install base + i3 packages"
  echo "  $0 minimal.txt       # Install minimal package set"
  echo ""
  echo "Brew packages are automatically loaded from brew/ subdirectory"
  echo "when corresponding APT package files are selected."
}

# Base directory for package files
PACKAGES_DIR="$PWD/setup-scripts/packages"
BREW_PACKAGES_DIR="$PACKAGES_DIR/brew"

# Default package files to use if none specified
DEFAULT_PACKAGE_FILES=("base.txt")

# APT Sources to add (format: "repository_line|keyring_url|keyring_path")
CUSTOM_APT_SOURCES=()

# Arrays to hold packages (will be populated from files)
APT_PACKAGES=()
BREW_PACKAGES=()
