#!/bin/bash

# Package manager wrapper script
# Supports apt and brew with package lists and configuration tracking

CONFIG_FILE="$HOME/.config/link-manager/config"
LINK_LISTS_DIR="$HOME/.config/link-manager/lists"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create necessary directories
mkdir -p "$(dirname "$CONFIG_FILE")"
mkdir -p "$LINK_LISTS_DIR"

# Initialize config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "# Link Manager Configuration" > "$CONFIG_FILE"
  echo "# Format: from:to" >> "$CONFIG_FILE"
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


# Create a single link
create_symlink() {
  local link_spec="$1"
  local from_path
  local to_path

  if [[ "$pkg_spec" == *":"* ]]; then
    from_path="${pkg_spec%%:*}"
    to_path="${pkg_spec##*:}"
  else
    log_error "Invalid link specification: $link_spec (use from_path:to_path format)"
    return 1
  fi

  log_info "Creating Link from $from_path to $to_path..."

  # TODO:

  # if to_path exist and from_path does not or is a symlink: create symlink
}

# Remove a link
remove_symlink() {
  local path="$1"
  local removed=false


  # TODO:

  # check if it is a symlink, then remove
  log_info "Removing $path ..."
  # check if a symlink points to it, then remove the symlink

  # else prompt no symlink

}

# Add link to configuration file
add_to_config() {
  local link_spec="$1"

  # Check if already in config
  if grep -Fxq "$link_spec" "$CONFIG_FILE"; then
    return 0
  fi

  echo "$link_spec" >> "$CONFIG_FILE"
  log_info "Added $link_spec to configuration"
}

# Remove link from configuration file
remove_from_config() {
  local link="$1"
  local temp_file=$(mktemp)

  # Remove lines containing the link
  grep -v ":$link$" "$CONFIG_FILE" > "$temp_file"
  mv "$temp_file" "$CONFIG_FILE"
  log_info "Removed $link from configuration"
}

# Install from link list file
install_from_list() {
  local list_file="$1"
  local full_path

  # Check if it's a .ln file in current directory
  if [ -f "$list_file" ]; then
    full_path="$list_file"
  # Check if it's in the link lists directory
  elif [ -f "$LINK_LISTS_DIR/$list_file" ]; then
    full_path="$LINK_LISTS_DIR/$list_file"
  else
    log_error "link list not found: $list_file"
    return 1
  fi

  log_info "Creating links from $full_path..."

  local failed=0
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    line=$(echo "$line" | xargs)
    [[ -z "$line" ]] && continue

    if ! create_symlink "$line"; then
      ((failed++))
    fi
  done < "$full_path"

  if [ $failed -eq 0 ]; then
    log_success "All linkst from $list_file created successfully"
  else
    log_warning "$failed links failed to create from $list_file"
  fi
}

# List installed packages
list_links() {
  log_info "links in configuration:"

  if [ ! -s "$CONFIG_FILE" ]; then
    echo "No links in configuration file"
    return 0
  fi

  # Group by package manager
  local links=""

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" == *:* ]]; then
      links="$links ${line##*:}"
    fi
  done < "$CONFIG_FILE"

  if [ -n "$links" ]; then
    echo -e "${GREEN}links:${NC}$links"
  fi
}

# Show usage information
usage() {
  echo "Usage: $0 <command> [arguments]"
  echo ""
  echo "Commands:"
  echo "  install <link_files...> Install link lists"
  echo "  remove <from/to>        Remove a link"
  echo "  create <from> <to>      creates a link"
  echo "  list                    List configured links"
  echo ""
  echo "Link format: from_path:to_path (e.g., ~/.config/nvim:~/.dotfiles/nvim, \$HOME/.zshrc:\$HOME/.dotfiles/.zshrc)"
  echo "Link lists: .ln files (e.g., dotfiles.ln, scripts.ln)"
  echo ""
  echo "Examples:"
  echo "  $0 create ~/.config/i3 ~/.dotfiles/i3"
  echo "  $0 install dotfiles.ln"
  echo "  $0 remove ~/.config/i3"
  echo "  $0 list"
  echo ""
  echo "Configuration file: $CONFIG_FILE"
  echo "Link lists directory: $LINK_LISTS_DIR"
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
        log_error "No link list specified for creation"
        exit 1
      fi

      for link_list in "$@"; do
        if [[ "$link_list" == *.ln ]]; then
          install_from_list "$link_list"
        fi
      done
      ;;
    "create")
      if [ ! $# -eq 2 ]; then
        log_error "No paths specified for creation"
        exit 1
      fi
      create_symlink "$1:$2"
      ;;
    "remove")
      if [ $# -eq 0 ]; then
        log_error "No path specified for removal"
        exit 1
      fi
      remove_link "$1"
      ;;
    "list")
      list_links
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
