#!/usr/bin/env bash

print_help() {
  cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

A system maintenance utility for Arch Linux that helps monitor system health,
manage updates, and clean up caches.

COMMANDS:
  status [SCOPE]        Display system status information
                        SCOPE options:
                          failed-services  Show only failed systemd services
                          services        Show failed services and recent errors
                          cache           Show cache sizes (pacman/yay, user, journal)
                          all             Show all status information (default)

  run [OPTIONS]         Run complete maintenance cycle:
                        - Display system status
                        - Update system packages
                        - Remove orphan packages
                        - Clear all caches
                        - Display final status
                        
                        OPTIONS:
                          --skip-status         Skip status checks
                          --skip-update         Skip system update
                          --orphan              Enable orphan package removal
                          --skip-cache          Skip all cache clearing
                          --skip-pacman-cache   Skip pacman/yay cache only
                          --skip-user-cache     Skip user cache only
                          --skip-journal        Skip journal cleanup only

  help                  Display this help message

EXAMPLES:
  $0 status                           # Show all system status
  $0 status cache                     # Show only cache sizes
  $0 status failed-services           # Show only failed services
  $0 run                              # Run full maintenance cycle
  $0 run --skip-update                # Run maintenance without updating
  $0 run --orphan                     # Run maintenance but keep orphan packages
  $0 run --skip-user-cache            # Run maintenance but keep user cache
  $0 run --skip-update --skip-journal # Skip update and journal cleanup
  $0 run --skip-cache                 # Only show status, update, and remove orphans

NOTES:
  - Requires sudo privileges for some operations
  - Automatically detects yay AUR helper, falls back to pacman
  - Orphan package removal can be risky - review packages before removing

ADDITIONAL FUNCTIONS (not exposed via CLI):
  - list_orphan_packages()    List orphan packages

EOF
}

failed_services() {
  systemctl --failed
}

services_journalctl() {
  sudo journalctl -p 3 -xb | tail -10
}

update_system() {
  if command -v yay > /dev/null 2>&1; then
    yay -Syu --noconfirm
  else
    sudo pacman -Syu --noconfirm
  fi

}

size_pacman_cash() {
  if command -v yay > /dev/null 2>&1; then
    du -sh ~/.cache/yay/ 2>/dev/null | awk '{print $1}' || echo "0"
  else
    du -sh /var/cache/pacman/pkg/ 2>/dev/null | awk '{print $1}' || echo "0"
  fi
}

clear_pacman_cash() {
  if command -v yay > /dev/null 2>&1; then
    yay -Sc --noconfirm
  else
    sudo pacman -Sc --noconfirm
  fi
}


size_user_cash() {
  du -sh ~/.cache/ | awk '{print $1}'
}

clear_user_cash() {
  rm -rf ~/.cache/*
}

list_orphan_packages() {
  if command -v yay > /dev/null 2>&1; then
  yay -Qtdq
  else
  pacman -Qtdq
  fi
}

size_orphan_packages() {
  local orphans
  
  # Get list of orphan packages
  if command -v yay > /dev/null 2>&1; then
    orphans=$(yay -Qtdq 2>/dev/null)
  else
    orphans=$(pacman -Qtdq 2>/dev/null)
  fi
  
  # If no orphans, return 0
  if [ -z "$orphans" ]; then
    echo "0"
    return
  fi
  
  # Calculate total size of orphan packages
  if command -v yay > /dev/null 2>&1; then
    echo "$orphans" | xargs yay -Qi 2>/dev/null | grep "Installed Size" | awk '{
      sum += $4
    } 
    END {
      if (sum < 1024)
        printf "%.1fK", sum
      else if (sum < 1024*1024)
        printf "%.1fM", sum/1024
      else
        printf "%.1fG", sum/(1024*1024)
    }'
  else
    echo "$orphans" | xargs pacman -Qi 2>/dev/null | grep "Installed Size" | awk '{
      sum += $4
    } 
    END {
      if (sum < 1024)
        printf "%.1fK", sum
      else if (sum < 1024*1024)
        printf "%.1fM", sum/1024
      else
        printf "%.1fG", sum/(1024*1024)
    }'
  fi
}

size_journal() {
  du -sh /var/log/journal/ | awk '{print $1}'
}

clear_journal() {
  sudo journalctl --vacuum-time=2weeks
}

remove_orphan_packages() {
  # First check if there are any orphan packages
  local orphans=$(list_orphan_packages 2>/dev/null)
  
  if [ -z "$orphans" ]; then
    echo "No orphan packages found."
    return 0
  fi
  
  # Display the orphan packages
  echo "Found orphan packages:"
  list_orphan_packages
  echo ""
  
  # Ask for confirmation
  echo "Removing orphan packages can be dangerous. Do you want to remove them? [Y/n]"
  read -r response
  
  # Default to Yes if empty, accept Y/y/yes/Yes, reject anything else
  case "$response" in
    [Yy]|[Yy][Ee][Ss]|"")
      echo "Removing orphan packages..."
      sudo pacman -Rns $(pacman -Qtdq)
      ;;
    *)
      echo "Cancelled. No packages were removed."
      return 1
      ;;
  esac
}

show_cache_sizes() {
      echo "Orphan packages takes $(size_orphan_packages) disk space"

      if command -v yay > /dev/null 2>&1; then
        echo "yay cache takes $(size_pacman_cash) disk space"
      else
        echo "pacman cache takes $(size_pacman_cash) disk space"
      fi

      echo "User cache takes $(size_user_cash) disk space"
      echo "Journal cache takes $(size_journal) disk space"
}

handle_status() {
  SCOPE=$1
  shift 1

  case "$SCOPE" in
    "failed-services") 
      failed_services
    ;;
    "services")
      failed_services
      services_journalctl
    ;;
    "cache")
      show_cache_sizes
    ;;
    *|all)
      echo 
      echo "====================================="
      echo "========== Failed services =========="
      echo "====================================="
      echo 
      failed_services
      echo 
      echo "============================================"
      echo "========== Latest journal entries =========="
      echo "============================================"
      echo 
      services_journalctl
      echo 
      echo "==============================="
      echo "========== Disk size =========="
      echo "==============================="
      echo 
      show_cache_sizes
    ;;
  esac
}

handle_run() {
  local skip_status=false
  local skip_update=false
  local skip_orphan=true
  local skip_cache=false
  local skip_pacman_cache=false
  local skip_user_cache=false
  local skip_journal=false
  
  # Parse flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-status)
        skip_status=true
        shift
        ;;
      --skip-update)
        skip_update=true
        shift
        ;;
      --orphan)
        skip_orphan=false
        shift
        ;;
      --skip-cache)
        skip_cache=true
        shift
        ;;
      --skip-pacman-cache)
        skip_pacman_cache=true
        shift
        ;;
      --skip-user-cache)
        skip_user_cache=true
        shift
        ;;
      --skip-journal)
        skip_journal=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Valid options: --skip-status, --skip-update, --skip-cache,"
        echo "               --skip-pacman-cache, --skip-user-cache, --skip-journal"
        return 1
        ;;
    esac
  done
  
  echo "=== Running System Maintenance ==="
  echo ""
  
  if [ "$skip_status" = false ]; then
    echo "--- System Status ---"
    handle_status "all"
    echo ""
  fi
  
  if [ "$skip_update" = false ]; then
    echo "--- Updating System ---"
    update_system
    echo ""
  fi

  if [ "$skip_orphan" = false ]; then
    echo "--- Remove orphan packages ---"
    remove_orphan_packages
    echo ""
  fi
  
  if [ "$skip_cache" = false ]; then
    echo "--- Clearing Caches ---"
    
    if [ "$skip_pacman_cache" = false ]; then
      clear_pacman_cash
    fi
    
    if [ "$skip_user_cache" = false ]; then
      clear_user_cash
    fi
    
    if [ "$skip_journal" = false ]; then
      clear_journal
    fi
    echo ""
  fi
  
  echo "=== Maintenance Complete ==="
  echo ""
  
  if [ "$skip_status" = false ]; then
    echo "Final Status:"
    handle_status "all"
  fi
}

handle_subcommands() {
  SUB=$1
  shift 1

  case "$SUB" in
    "status")
      handle_status $@
    ;;
    "run")
      handle_run $@
    ;;
    *)
      print_help
    ;;
  esac
  
}

main() {
  handle_subcommands $@
}

main $@
