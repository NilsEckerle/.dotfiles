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
check_sudo() {
  return 0
}

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

# Global array to store selected scripts
declare -a SELECTED_SCRIPTS=()

# Function to choose from multiple options during configuration
choose_option() {
  local -a options=("$@")
  local choice

  echo
  echo "Multiple options available:"
  for i in "${!options[@]}"; do
    local desc=$(get_script_description "${options[$i]}")
    printf "  %d) %s - %s\n" $((i+1)) "${options[$i]}" "$desc"
  done

  while true; do
    echo
    read -p "Please select an option (1-${#options[@]}), or 's' to skip this step: " choice </dev/tty

      if [[ "$choice" == "s" || "$choice" == "S" ]]; then
        echo "Skipping this step."
        return 1
      elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
        echo "Selected: ${options[$((choice-1))]}"
        SELECTED_SCRIPTS+=("${options[$((choice-1))]}")
        return 0
      else
        log_error "Invalid choice. Please enter a number between 1 and ${#options[@]}, or 's' to skip."
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
      return 1
    fi
  else
    log_warning "Script $script is not executable. Making it executable..."
    chmod +x "$script"
    if ./"$script"; then
      log_success "Completed: $script"
    else
      log_error "Failed to execute: $script"
      return 1
    fi
  fi
  echo
  return 0
}

# Pre-authenticate sudo and keep it alive
setup_sudo() {
  log_info "Setting up sudo authentication..."

  # Check if we need sudo
  if ! sudo -n true 2>/dev/null; then
    log_info "Please enter your password for sudo authentication:"
    sudo -v
  fi

  # Keep sudo alive in background
  while true; do 
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &

  log_success "Sudo authentication configured"
}

# Configuration phase - select all scripts to run
configure_installation() {
  local script_data="$1"

  log_info "=== CONFIGURATION PHASE ==="
  echo "Please select which scripts to run for each step."
  echo

  # Clear the global array
  SELECTED_SCRIPTS=()

  while IFS=':' read -r order scripts_str; do
    IFS=' ' read -ra scripts <<< "$scripts_str"

    echo "Step $order:"

    if [[ ${#scripts[@]} -eq 1 ]]; then
      # Only one script in this group, auto-select it
      local desc=$(get_script_description "${scripts[0]}")
      echo "  → ${scripts[0]} - $desc (auto-selected)"
      SELECTED_SCRIPTS+=("${scripts[0]}")
    else
      # Multiple scripts, let user choose
      echo "  Multiple options available for this step:"
      for script in "${scripts[@]}"; do
        local desc=$(get_script_description "$script")
        echo "    - $script - $desc"
      done

      choose_option "${scripts[@]}"
    fi
    echo
  done <<< "$script_data"

  # Show summary of selected scripts
  echo
  log_info "=== INSTALLATION SUMMARY ==="
  if [[ ${#SELECTED_SCRIPTS[@]} -eq 0 ]]; then
    log_warning "No scripts selected for installation."
    exit 0
  fi

  echo "The following scripts will be executed:"
  for i in "${!SELECTED_SCRIPTS[@]}"; do
    local desc=$(get_script_description "${SELECTED_SCRIPTS[$i]}")
    printf "  %d. %s - %s\n" $((i+1)) "${SELECTED_SCRIPTS[$i]}" "$desc"
  done
  echo

  read -p "Proceed with installation? (y/N): " confirm </dev/tty
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    log_info "Installation cancelled."
    exit 0
  fi
}

# Execution phase - run all selected scripts unattended
execute_installation() {
  local -a selected_scripts=("$@")

  log_info "=== EXECUTION PHASE ==="
  echo "Starting unattended installation of ${#selected_scripts[@]} scripts..."
    echo "You can now leave this running - it will complete without user interaction."
    echo

    setup_sudo

    local failed_scripts=()
    local successful_scripts=()

    # Execute each selected script
    for script in "${selected_scripts[@]}"; do
      if execute_script "$script"; then
        successful_scripts+=("$script")
      else
        failed_scripts+=("$script")
        log_error "Script $script failed. Continuing with remaining scripts..."
      fi
    done

    # Final summary
    echo
    log_info "=== INSTALLATION COMPLETE ==="

    if [[ ${#successful_scripts[@]} -gt 0 ]]; then
      log_success "Successfully completed ${#successful_scripts[@]} scripts:"
        for script in "${successful_scripts[@]}"; do
          echo "  ✓ $script"
        done
    fi

    if [[ ${#failed_scripts[@]} -gt 0 ]]; then
      echo
      log_error "Failed scripts (${#failed_scripts[@]}):"
        for script in "${failed_scripts[@]}"; do
          echo "  ✗ $script"
        done
        echo
        log_warning "Some scripts failed. Please review the output above for details."
        return 1
      else
        echo
        log_success "All selected scripts completed successfully!"
        return 0
    fi
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

  # Check sudo privileges
  check_sudo

  # Find and group scripts
  local script_data
  script_data=$(find_and_group_scripts)

  if [[ -z "$script_data" ]]; then
    log_error "No installation scripts found."
    exit 1
  fi

  # Show overview
  log_info "Available installation scripts:"
  while IFS=':' read -r order scripts_str; do
    IFS=' ' read -ra scripts <<< "$scripts_str"

    if [[ ${#scripts[@]} -eq 1 ]]; then
      local desc=$(get_script_description "${scripts[0]}")
      echo "  Step $order: ${scripts[0]} - $desc"
    else
      echo "  Step $order: Multiple options available"
      for script in "${scripts[@]}"; do
        local desc=$(get_script_description "$script")
        echo "    - $script - $desc"
      done
    fi
  done <<< "$script_data"

  echo

  # Configuration phase
  configure_installation "$script_data"

  # Execution phase
  execute_installation "${SELECTED_SCRIPTS[@]}"
}

# Run main function
main "$@"
