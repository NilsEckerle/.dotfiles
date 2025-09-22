#!/bin/bash

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

# Check if user has sudo privileges
if ! groups "$USER" | grep -q '\bsudo\b'; then
  log_error "User $USER is not in sudo group. Please run as root first:"
  log_error "  usermod -aG sudo $USER"
  log_error "  echo \"$USER ALL=(ALL:ALL) ALL\" >> /etc/sudoers.d/$USER"
  log_error "Then log out/in and run this script as $USER"
  exit 1
fi

# Check if running with sudo
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  log_error "This script must be run with sudo!"
  log_error "Run it as: sudo $0"
  log_error ""
  log_error "Note: This will install dotfiles in the correct user location"
  log_error "using \$SUDO_USER environment variable."
  exit 1
fi

# Ensure we have the original user information
if [ -z "$SUDO_USER" ]; then
  log_error "SUDO_USER environment variable not found!"
  log_error "Please run this script with 'sudo' command, not as root directly."
  exit 1
fi

# Function to get script description from filename
get_script_description() {
  local filename="$1"
  # Remove numbers and extension, replace hyphens with spaces, capitalize
  echo "$filename" | sed 's/^[0-9]\{3\}-//; s/\.sh$//; s/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}

# Function to find all install scripts and group them by order number
find_and_group_scripts() {
  local -A script_groups
  local -a order_numbers

  # Find all numbered scripts
  for script in [0-9][0-9][0-9]-*.sh; do
    if [[ -f "$script" && "$script" != "interactive-install.sh" ]]; then
      # Extract order number (first two digits)
      local order="${script:0:2}"
      # Extract full prefix (first three digits)
      local prefix="${script:0:3}"

      # Add to script groups
      if [[ -z "${script_groups[$order]}" ]]; then
        script_groups[$order]="$script"
        order_numbers+=("$order")
      else
        script_groups[$order]+=" $script"
      fi
    fi
  done

  # Sort order numbers
  IFS=$'\n' order_numbers=($(sort -n <<<"${order_numbers[*]}"))
  unset IFS

  # Return the grouped scripts
  for order in "${order_numbers[@]}"; do
    echo "$order:${script_groups[$order]}"
  done
}

# Function to choose from multiple options
choose_option() {
  local order="$1"
  shift
  local options=("$@")

  if [[ ${#options[@]} -eq 1 ]]; then
    echo "${options[0]}"
    return
  fi

  echo
  log_info "Multiple options found for step $order:"
  for i in "${!options[@]}"; do
    local desc=$(get_script_description "${options[$i]}")
    echo "  $((i+1)). ${options[$i]} - $desc"
  done
  echo "  0. Skip this step"

  while true; do
    read -p "Choose an option (0-${#options[@]}): " choice

      if [[ "$choice" == "0" ]]; then
        echo ""
        return
      elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [[ "$choice" -le "${#options[@]}" ]]; then
        echo "${options[$((choice-1))]}"
        return
      else
        log_error "Invalid choice. Please enter a number between 0 and ${#options[@]}."
      fi
    done
  }

# Function to execute a script
execute_script() {
  local script="$1"
  local desc=$(get_script_description "$script")

  log_info "Executing: $script - $desc"
  echo "----------------------------------------"

  if [[ -x "$script" ]]; then
    if ./"$script"; then
      log_success "Completed: $script"
    else
      log_error "Failed to execute: $script"
      echo
      read -p "Do you want to continue with the remaining scripts? (y/N): " continue_choice
      if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        log_error "Installation aborted."
        exit 1
      fi
    fi
  else
    log_warning "Script $script is not executable. Making it executable..."
    chmod +x "$script"
    if ./"$script"; then
      log_success "Completed: $script"
    else
      log_error "Failed to execute: $script"
      echo
      read -p "Do you want to continue with the remaining scripts? (y/N): " continue_choice
      if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        log_error "Installation aborted."
        exit 1
      fi
    fi
  fi
  echo
}

# Main function
main() {
  log_info "Interactive Installation Script"
  echo "==============================="
  echo

  # Check if we're in the right directory
  if [[ ! -f "interactive-install.sh" ]]; then
    log_error "Please run this script from the directory containing the install scripts."
    exit 1
  fi

  # Find and group scripts
  local script_data
  script_data=$(find_and_group_scripts)

  if [[ -z "$script_data" ]]; then
    log_error "No installation scripts found."
    exit 1
  fi

  # Show overview
  log_info "Found installation scripts:"
  local selected_scripts=()

  while IFS=':' read -r order scripts_str; do
    IFS=' ' read -ra scripts <<< "$scripts_str"

    if [[ ${#scripts[@]} -eq 1 ]]; then
      local desc=$(get_script_description "${scripts[0]}")
      echo "  Step $order: ${scripts[0]} - $desc"
      selected_scripts+=("${scripts[0]}")
    else
      echo "  Step $order: Multiple options available"
      for script in "${scripts[@]}"; do
        local desc=$(get_script_description "$script")
        echo "    - $script - $desc"
      done
    fi
  done <<< "$script_data"

  echo
  read -p "Do you want to proceed with the installation? (y/N): " proceed
  if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    log_info "Installation cancelled."
    exit 0
  fi

  echo
  log_info "Starting installation process..."
  echo

  # Process each order group
  while IFS=':' read -r order scripts_str; do
    IFS=' ' read -ra scripts <<< "$scripts_str"

    local chosen_script
    chosen_script=$(choose_option "$order" "${scripts[@]}")

    if [[ -n "$chosen_script" ]]; then
      execute_script "$chosen_script"
    else
      log_warning "Skipped step $order"
      echo
    fi
  done <<< "$script_data"

  log_success "Installation process completed!"
}

# Run main function
main "$@"
