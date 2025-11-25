#!/usr/bin/env bash

# Ready or Not Mod Manager Script
# Manages symlinks for Ready or Not game mods

set -euo pipefail

# Default paths
DEFAULT_READY_OR_NOT_PACK_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Ready\ Or\ Not/ReadyOrNot/Content/Paks"
DEFAULT_MOD_LOCATION="$HOME/ready-or-not_mods"
SCRIPT_NAME=$(basename "$0")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
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
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Guard root execution
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root for security reasons."
        log_error "Please run as a regular user."
        exit 1
    fi
}

# Find Ready or Not Paks directory dynamically
find_ready_or_not_dir() {
    local search_paths=(
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Ready Or Not/ReadyOrNot/Content/Paks"
        "$HOME/.local/share/Steam/steamapps/common/Ready Or Not/ReadyOrNot/Content/Paks"
        "$HOME/.steam/steam/steamapps/common/Ready Or Not/ReadyOrNot/Content/Paks"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Get user confirmation for paths
get_paths() {
    local ready_or_not_dir
    local mod_dir
    
    # Try to find Ready or Not directory
    if ready_or_not_dir=$(find_ready_or_not_dir); then
        log_info "Found Ready or Not Paks directory: $ready_or_not_dir"
        read -p "Use this directory? [Y/n]: " -r response
        if [[ $response =~ ^[Nn]$ ]]; then
            read -p "Enter Ready or Not Paks directory path: " -r ready_or_not_dir
        fi
    else
        log_warning "Ready or Not Paks directory not found automatically."
        read -p "Enter Ready or Not Paks directory path [$DEFAULT_READY_OR_NOT_PACK_DIR]: " -r ready_or_not_dir
        ready_or_not_dir=${ready_or_not_dir:-$DEFAULT_READY_OR_NOT_PACK_DIR}
    fi
    
    # Expand tilde and remove escaping
    ready_or_not_dir=$(eval echo "$ready_or_not_dir")
    
    # Get mod directory
    read -p "Enter mod directory path [$DEFAULT_MOD_LOCATION]: " -r mod_dir
    mod_dir=${mod_dir:-$DEFAULT_MOD_LOCATION}
    mod_dir=$(eval echo "$mod_dir")
    
    # Validate directories
    if [[ ! -d "$ready_or_not_dir" ]]; then
        log_error "Ready or Not Paks directory does not exist: $ready_or_not_dir"
        exit 1
    fi
    
    if [[ ! -d "$mod_dir" ]]; then
        log_error "Mod directory does not exist: $mod_dir"
        log_info "Create it first: mkdir -p '$mod_dir'"
        exit 1
    fi
    
    echo "$ready_or_not_dir|$mod_dir"
}

# Install mods (create symlinks)
install_mods() {
    log_info "Installing mods..."
    
    local paths
    paths=$(get_paths)
    local ready_or_not_dir="${paths%|*}"
    local mod_dir="${paths#*|}"
    
    local mod_count=0
    local success_count=0
    
    # Find all .pak files in mod directory
    while IFS= read -r -d '' mod_file; do
        ((mod_count++))
        local mod_name
        mod_name=$(basename "$mod_file")
        local target_link="$ready_or_not_dir/$mod_name"
        
        if [[ -L "$target_link" ]]; then
            log_warning "Symlink already exists: $mod_name"
        elif [[ -e "$target_link" ]]; then
            log_error "File already exists (not a symlink): $mod_name"
        else
            if ln -s "$mod_file" "$target_link"; then
                log_success "Created symlink for: $mod_name"
                ((success_count++))
            else
                log_error "Failed to create symlink for: $mod_name"
            fi
        fi
    done < <(find "$mod_dir" -name "*.pak" -type f -print0)
    
    if [[ $mod_count -eq 0 ]]; then
        log_warning "No .pak files found in $mod_dir"
    else
        log_info "Processed $mod_count mod files, successfully linked $success_count"
    fi
}

# Uninstall mods (remove symlinks)
uninstall_mods() {
    log_info "Uninstalling mods..."
    
    local paths
    paths=$(get_paths)
    local ready_or_not_dir="${paths%|*}"
    local mod_dir="${paths#*|}"
    
    local removed_count=0
    
    # Find and remove symlinks that point to mod directory
    while IFS= read -r -d '' link_file; do
        local link_target
        if link_target=$(readlink "$link_file") && [[ "$link_target" == "$mod_dir"/* ]]; then
            local link_name
            link_name=$(basename "$link_file")
            if rm "$link_file"; then
                log_success "Removed symlink: $link_name"
                ((removed_count++))
            else
                log_error "Failed to remove symlink: $link_name"
            fi
        fi
    done < <(find "$ready_or_not_dir" -type l -print0 2>/dev/null)
    
    log_info "Removed $removed_count mod symlinks"
}

# Show help
show_help() {
    cat << EOF
$SCRIPT_NAME - Ready or Not Mod Manager

DESCRIPTION:
    Manages Ready or Not game mods by creating/removing symlinks between
    your mod directory and the game's Paks directory.

USAGE:
    $SCRIPT_NAME [OPTION]

OPTIONS:
    -i, --install     Install mods (create symlinks)
    -u, --uninstall   Uninstall mods (remove symlinks)
    -h, --help        Show this help message

DEFAULT PATHS:
    Game Paks Dir: $DEFAULT_READY_OR_NOT_PACK_DIR
    Mod Directory: $DEFAULT_MOD_LOCATION

NOTES:
    - This script should not be run as root
    - Only .pak files are processed
    - Existing files/symlinks are not overwritten
    - The script will prompt you to confirm or change default paths

EXAMPLES:
    $SCRIPT_NAME --install      # Install all mods from mod directory
    $SCRIPT_NAME -u            # Remove all mod symlinks
    $SCRIPT_NAME --help        # Show this help

EOF
}

# Main function
main() {
    check_root
    
    case "${1:-}" in
        -i|--install)
            install_mods
            ;;
        -u|--uninstall)
            uninstall_mods
            ;;
        -h|--help)
            show_help
            ;;
        "")
            log_error "No option provided. Use -h or --help for usage information."
            exit 1
            ;;
        *)
            log_error "Invalid option: $1"
            log_error "Use -h or --help for usage information."
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
