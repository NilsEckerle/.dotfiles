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
  zathura
  zathura-pdf-mupdf
  nvim
  feh
)

SYMLINKS=()

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

create_nvim_desktop() {
  echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Neovim
Comment=Edit text files
Exec=kitty nvim %F
Icon=nvim
Terminal=false
Categories=Utility;TextEditor;
MimeType=text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;text/x-python;text/x-script.python;application/x-yaml;text/x-yaml;application/json;text/markdown;text/x-markdown;text/html;application/xml;text/xml;text/x-lua;text/x-rust;text/x-go;text/csv;application/javascript;text/x-sh;" > ~/.local/share/applications/nvim.desktop
}

create_feh_desktop() {
  echo "[Desktop Entry]
Version=1.0
Type=Application
Name=feh
Comment=Image Viewer
Exec=feh %F
Icon=feh
Terminal=false
Categories=Graphics;Viewer;
MimeType=image/png;image/jpeg;image/jpg;image/gif;image/bmp;image/webp;image/tiff;image/svg+xml;" > ~/.local/share/applications/feh.desktop
}

create_zathura_desktop() {
  echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Zathura
Comment=PDF Viewer
Exec=zathura %F
Icon=org.pwmt.zathura
Terminal=false
Categories=Office;Viewer;
MimeType=application/pdf;application/x-pdf;application/x-bzpdf;application/x-gzpdf;application/x-xzpdf;application/postscript;application/x-bzpostscript;application/x-gzpostscript;image/x-eps;image/x-bzeps;image/x-gzeps;application/x-dvi;application/x-bzdvi;application/x-gzdvi;image/vnd.djvu;" > ~/.local/share/applications/zathura.desktop
}

setup_default_apps() {
  log_info "Creating desktop entries..."
  
  # Create .local/share/applications if it doesn't exist
  mkdir -p ~/.local/share/applications
  
  create_nvim_desktop
  log_success "Created nvim.desktop"
  
  create_feh_desktop
  log_success "Created feh.desktop"
  
  create_zathura_desktop
  log_success "Created zathura.desktop"

  log_info "Updating desktop database..."
  update-desktop-database ~/.local/share/applications

  log_info "Setting default applications..."
  
  # Set Neovim for text files
  xdg-mime default nvim.desktop text/plain
  xdg-mime default nvim.desktop text/x-python
  xdg-mime default nvim.desktop application/x-yaml
  xdg-mime default nvim.desktop application/json
  xdg-mime default nvim.desktop text/markdown
  xdg-mime default nvim.desktop text/html
  xdg-mime default nvim.desktop application/xml
  xdg-mime default nvim.desktop application/javascript
  xdg-mime default nvim.desktop text/x-sh
  xdg-mime default nvim.desktop application/x-shellscript
  
  # Set feh for images
  xdg-mime default feh.desktop image/png
  xdg-mime default feh.desktop image/jpeg
  xdg-mime default feh.desktop image/jpg
  xdg-mime default feh.desktop image/gif
  xdg-mime default feh.desktop image/webp
  xdg-mime default feh.desktop image/bmp
  xdg-mime default feh.desktop image/tiff
  
  # Set Zathura for PDFs
  xdg-mime default zathura.desktop application/pdf
  
  log_success "Default applications configured!"
}

main() {
  install_system_packages
  create_symlinks
  setup_default_apps
}

main
