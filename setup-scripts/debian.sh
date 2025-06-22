#!/bin/bash

# Debian 12 Dotfiles Setup Script with Profile Selection
# Run this script from your ~/.dotfiles directory

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# PACKAGE LISTS CONFIGURATION
# ============================================================================

# APT Package Lists
APT_PACKAGES_MINIMAL=(
    "sudo"
    "zsh" 
    "tmux"
    "vim"
    "curl"
    "wget"
    "git"
    "build-essential"
    "procps"
    "file"
    "python3"
    "python3-pip"
    "syncthing"
    "flatpak"
)

APT_PACKAGES_FULL=(
    "kitty"
    "ripgrep"
    "figlet"
    "fzf"
    "tldr"
    "python3-venv"
    "yarnpkg"
    "nodejs"
    "npm"
    "htop"
    "tree"
    "unzip"
    "zip"
    "gnome-software-plugin-flatpak"
		"pavucontrol"
		"pulseaudio-module-bluetooth"
		"blueman"
)

# GUI-specific packages
APT_PACKAGES_GUI=(
    "xorg"
    "lightdm"
    "firefox-esr"
    "thunar"
    "xfce4-terminal"
    "vlc"
    "gimp"
    "libreoffice"
    "gparted"
    "synaptic"
		"nemo"
)

# i3 window manager packages
APT_PACKAGES_I3=(
    "i3"
    "i3blocks"
    "i3status"
    "i3lock"
    "dmenu"
    "feh"
    "rofi"
    "compton"
    "nitrogen"
    "scrot"
)

# SSH server package
APT_PACKAGES_SSH=(
    "openssh-server"
)

# Add this to your package lists section (around line 50-60)
APT_PACKAGES_FLATPAK=(
)

# Flatpak Package Lists
FLATPAK_PACKAGES_MINIMAL=()

FLATPAK_PACKAGES_FULL=(
    "com.valvesoftware.Steam"
    #"com.discordapp.Discord"
    #"com.spotify.Client"
)

# Homebrew Package Lists
BREW_PACKAGES_MINIMAL=(
    "neovim"
    "zoxide"
)

BREW_PACKAGES_FULL=(
    "neovim"
    "zoxide"
    "fd"
    "lazygit"
)

# Snap Package Lists
SNAP_PACKAGES_MINIMAL=()

SNAP_PACKAGES_FULL=(
    "discord"
    "spotify"
    "code --classic"
    "postman"
    "slack --classic"
)

# APT Sources to add (format: "repository_line|keyring_url|keyring_path")
# Example: "deb [signed-by=/usr/share/keyrings/example.gpg] https://example.com/apt stable main|https://example.com/key.gpg|/usr/share/keyrings/example.gpg"
CUSTOM_APT_SOURCES=(
    # Syncthing repository
    "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable|https://syncthing.net/release-key.txt|/usr/share/keyrings/syncthing-archive-keyring.gpg"
    # needed for steam
    "deb http://deb.debian.org/debian/ bookworm main contrib non-free"
    # Add custom repositories here as needed
    # "deb [signed-by=/usr/share/keyrings/example.gpg] https://example.com/apt stable main|https://example.com/key.gpg|/usr/share/keyrings/example.gpg"
)

# ============================================================================
# PROFILE AND INSTALLATION VARIABLES
# ============================================================================

# Profile variables
PROFILE=""
ENABLE_SSH=false
ENABLE_GUI=false
INSTALL_I3=false
INSTALL_LEVEL="minimal"  # minimal or full

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

# Function to prompt for profile selection
select_profile() {
    echo ""
    echo -e "${BLUE}=== Debian Setup Profile Selection ===${NC}"
    echo ""
    echo "Please select your installation profile:"
    echo ""
    echo "1) i3wm (default) - Desktop environment with i3 window manager"
    echo "   - Installs i3 window manager and boots into GUI"
    echo "   - SSH disabled by default"
    echo "   - Full desktop experience"
    echo ""
    echo "2) headless - Server/headless configuration"
    echo "   - No GUI, boots to TTY"
    echo "   - SSH enabled with key-only authentication"
    echo "   - Minimal system resources"
    echo ""
    echo "3) custom - Custom configuration"
    echo "   - Choose your own options"
    echo "   - Interactive prompts for SSH, GUI, etc."
    echo ""
    
    while true; do
        read -p "Enter your choice (1-3): " choice
        case $choice in
            1)
                PROFILE="i3wm"
                ENABLE_SSH=false
                ENABLE_GUI=true
                INSTALL_I3=true
                INSTALL_LEVEL="full"
                log_success "Selected profile: i3wm (default)"
                break
                ;;
            2)
                PROFILE="headless"
                ENABLE_SSH=true
                ENABLE_GUI=false
                INSTALL_I3=false
                INSTALL_LEVEL="minimal"
                log_success "Selected profile: headless"
                break
                ;;
            3)
                PROFILE="custom"
                log_success "Selected profile: custom"
                configure_custom_profile
                break
                ;;
            *)
                log_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    
    echo ""
    log_info "Profile configuration:"
    log_info "  Profile: $PROFILE"
    log_info "  Install level: $INSTALL_LEVEL"
    log_info "  SSH: $([ "$ENABLE_SSH" = true ] && echo "enabled" || echo "disabled")"
    log_info "  GUI: $([ "$ENABLE_GUI" = true ] && echo "enabled" || echo "disabled")"
    log_info "  i3wm: $([ "$INSTALL_I3" = true ] && echo "enabled" || echo "disabled")"
    echo ""
    
    read -p "Continue with this configuration? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled by user"
        exit 0
    fi
}

# Function to configure custom profile options
configure_custom_profile() {
    echo ""
    echo -e "${YELLOW}=== Custom Profile Configuration ===${NC}"
    
    # Installation level
    while true; do
        read -p "Installation level - (m)inimal or (f)ull? (m/F): " level_choice
        case $level_choice in
            [Mm]*)
                INSTALL_LEVEL="minimal"
                log_info "Minimal installation selected"
                break
                ;;
            [Ff]*|"")
                INSTALL_LEVEL="full"
                log_info "Full installation selected (includes apps like Discord, Steam, Spotify)"
                break
                ;;
            *)
                log_error "Please answer m for minimal or f for full"
                ;;
        esac
    done
    
    # SSH configuration
    while true; do
        read -p "Enable SSH server? (y/N): " ssh_choice
        case $ssh_choice in
            [Yy]*)
                ENABLE_SSH=true
                log_info "SSH will be enabled"
                break
                ;;
            [Nn]*|"")
                ENABLE_SSH=false
                log_info "SSH will be disabled"
                break
                ;;
            *)
                log_error "Please answer y or n"
                ;;
        esac
    done
    
    # GUI configuration
    while true; do
        read -p "Install GUI components? (y/N): " gui_choice
        case $gui_choice in
            [Yy]*)
                ENABLE_GUI=true
                log_info "GUI components will be installed"
                
                # Ask about i3 if GUI is enabled
                while true; do
                    read -p "Install i3 window manager? (y/N): " i3_choice
                    case $i3_choice in
                        [Yy]*)
                            INSTALL_I3=true
                            log_info "i3 window manager will be installed"
                            break
                            ;;
                        [Nn]*|"")
                            INSTALL_I3=false
                            log_info "i3 window manager will not be installed"
                            break
                            ;;
                        *)
                            log_error "Please answer y or n"
                            ;;
                    esac
                done
                break
                ;;
            [Nn]*|"")
                ENABLE_GUI=false
                INSTALL_I3=false
                log_info "GUI components will not be installed"
                break
                ;;
            *)
                log_error "Please answer y or n"
                ;;
        esac
    done
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "This script should NOT be run as root!"
    log_error "It will install dotfiles in the wrong location (/root instead of your user home)"
    log_error ""
    log_error "If your user is not in sudo group, run this as root first:"
    log_error "  usermod -aG sudo your-username"
    log_error ""
    log_error "Then log out/in and run this script as your regular user."
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

# Check if script is run from dotfiles directory
if [ ! -f "README.md" ] || [ ! -d "nvim" ] || [ ! -d "setup-scripts" ]; then
    log_error "Please run this script from your ~/.dotfiles directory"
    exit 1
fi

DOTFILES_DIR=$(pwd)
log_info "Dotfiles directory: $DOTFILES_DIR"

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
        "software-properties-common"
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

# Function to add custom APT sources
add_apt_sources() {
    if [ ${#CUSTOM_APT_SOURCES[@]} -eq 0 ]; then
        log_info "No custom APT sources to add"
        return
    fi

    log_info "Adding custom APT sources..."
    
    for source_entry in "${CUSTOM_APT_SOURCES[@]}"; do
        # Skip empty entries
        [ -z "$source_entry" ] && continue
        
        # Parse the source entry (format: "repo_line|key_url|keyring_path")
        IFS='|' read -r repo_line key_url keyring_path <<< "$source_entry"
        
        # Extract repository name for logging
        repo_name=$(echo "$repo_line" | grep -o 'https://[^/]*' | sed 's|https://||' | head -n1)
        log_info "Adding repository: $repo_name"
        
        # Download and add the GPG key
        if [ -n "$key_url" ] && [ -n "$keyring_path" ]; then
            log_info "Downloading GPG key from $key_url"
            curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path"
            sudo chmod 644 "$keyring_path"
            log_success "GPG key added to $keyring_path"
        fi
        
        # Add the repository
        echo "$repo_line" | sudo tee "/etc/apt/sources.list.d/$(basename "$keyring_path" .gpg).list" > /dev/null
        log_success "Repository added: $repo_name"
    done
    
    # Update package list after adding sources
    log_info "Updating package list after adding custom sources..."
    sudo apt update
    log_success "Package list updated"
}

# Function to enable contrib and non-free repositories for Steam
enable_contrib_nonfree() {
    if [ "$INSTALL_LEVEL" = "full" ] && [ "$ENABLE_GUI" = true ]; then
        log_info "Enabling contrib and non-free repositories for Steam support..."
        
        # Check if contrib and non-free are already enabled
        if ! grep -q "contrib" /etc/apt/sources.list; then
            # Backup original sources.list
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            
            # Add contrib and non-free to main repository lines
            sudo sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
            
            # Update package list
            sudo apt update
            log_success "Contrib and non-free repositories enabled"
        else
            log_success "Contrib and non-free repositories already enabled"
        fi
        
        # Enable multiarch for 32-bit support (required for Steam)
        log_info "Enabling 32-bit architecture support for Steam..."
        sudo dpkg --add-architecture i386
        sudo apt update
        log_success "32-bit architecture support enabled"
    fi
}

# Function to install packages via apt
install_apt_packages() {
    log_info "Installing APT packages (level: $INSTALL_LEVEL)..."
    
    # Install essential tools first (needed for adding custom sources)
    install_essential_tools

    # Enable contrib/non-free and multiarch for Steam if needed
    enable_contrib_nonfree
    
    # Add custom APT sources
    add_apt_sources
    
    # Start with base packages based on install level
    local packages=()
    packages=("${APT_PACKAGES_MINIMAL[@]}")

    # Add full packages if enabled
    if [ "$INSTALL_LEVEL" = "full" ]; then
        packages+=("${APT_PACKAGES_FULL[@]}")
    fi

    # Add SSH server if enabled
    if [ "$ENABLE_SSH" = true ]; then
        packages+=("${APT_PACKAGES_SSH[@]}")
    fi

    # Add GUI packages if enabled
    if [ "$ENABLE_GUI" = true ]; then
        packages+=("${APT_PACKAGES_GUI[@]}")
    fi

    # Add i3 packages if enabled
    if [ "$INSTALL_I3" = true ]; then
        packages+=("${APT_PACKAGES_I3[@]}")
    fi

    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log_success "$package is already installed"
        else
            log_info "Installing $package..."
            sudo apt install -y "$package"
            log_success "$package installed"
        fi
    done
}

# Function to install Flatpak
install_flatpak() {
    log_info "Installing Flatpak..."

    # Install Flatpak package
    for package in "${APT_PACKAGES_FLATPAK[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            log_success "$package is already installed"
        else
            log_info "Installing $package..."
            sudo apt install -y "$package"
            log_success "$package installed"
        fi
    done

    # Add Flathub repository (the main Flatpak repository)
    log_info "Adding Flathub repository..."
    if ! flatpak remotes | grep -q "flathub"; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        log_success "Flathub repository added"
    else
        log_success "Flathub repository already exists"
    fi
}

# Function to install Flatpak packages
install_flatpak_packages() {
    # Only install Flatpak packages for full installations
    if [ "$INSTALL_LEVEL" != "full" ]; then
        log_info "Skipping Flatpak packages (minimal installation)"
        return
    fi

    log_info "Installing Flatpak packages..."

    # Start with base packages based on install level
    local packages=()
    packages=("${FLATPAK_PACKAGES_MINIMAL[@]}")

    # Add full packages if enabled
    if [ "$INSTALL_LEVEL" = "full" ]; then
        packages+=("${FLATPAK_PACKAGES_FULL[@]}")
    fi

    # Install each package
    for package in "${packages[@]}"; do
        if flatpak list | grep -q "$package"; then
            log_success "$package is already installed"
        else
            log_info "Installing $package via Flatpak..."
            sudo flatpak install -y flathub "$package"
            log_success "$package installed via Flatpak"
        fi
    done
}

# Function to install Homebrew
install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew is already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
}

# Function to install packages via Homebrew
install_brew_packages() {
    log_info "Installing Homebrew packages (level: $INSTALL_LEVEL)..."
    
    # Ensure brew is in PATH
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    local packages=()
    packages=("${BREW_PACKAGES_MINIMAL[@]}")

    if [ "$INSTALL_LEVEL" = "full" ]; then
        packages+=("${BREW_PACKAGES_FULL[@]}")
    fi

    for package in "${packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_success "$package is already installed via brew"
        else
            log_info "Installing $package via brew..."
            brew install "$package"
            log_success "$package installed via brew"
        fi
    done
}

# Function to install Snap packages
install_snap_packages() {
    # Skip snap installation if minimal or GUI not enabled
    if [ "$INSTALL_LEVEL" = "minimal" ] || [ "$ENABLE_GUI" != true ]; then
        log_info "Snap packages skipped (minimal install or no GUI)"
        return
    fi

    # Check if snapd is installed
    if ! command_exists snap; then
        log_info "Installing snapd..."
        sudo apt install -y snapd
        sudo systemctl enable snapd
        sudo systemctl start snapd
        # Wait for snap to be ready
        sudo snap wait system seed.loaded
        log_success "Snapd installed and started"
    fi

    log_info "Installing Snap packages..."
    
    local packages=("${SNAP_PACKAGES_FULL[@]}")

    for package in "${packages[@]}"; do
        # Handle packages with flags (like --classic)
        package_name=$(echo "$package" | cut -d' ' -f1)
        
        if snap list | grep -q "^$package_name "; then
            log_success "$package_name is already installed via snap"
        else
            log_info "Installing $package via snap..."
            sudo snap install $package
            log_success "$package installed via snap"
        fi
    done
}

# Function to install TPM (Tmux Plugin Manager)
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [ -d "$tpm_dir" ]; then
        log_success "TPM (Tmux Plugin Manager) is already installed"
        return
    fi
    
    log_info "Installing TPM (Tmux Plugin Manager)..."
    
    # Create tmux plugins directory
    mkdir -p "$HOME/.tmux/plugins"
    
    # Clone TPM repository
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    
    log_success "TPM installed"
    log_info "TPM installed to $tmp_dir"
    log_warning "After tmux configuration is set up, press prefix + I to install plugins"
}

# Function to create symlinks
create_symlinks() {
    log_info "Creating symlinks for configuration files..."
    
    # Create .local/bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Define config mappings: source_path:target_path
    local configs=(
        "nvim:$HOME/.config/nvim"
        "kitty:$HOME/.config/kitty"
        "alacritty:$HOME/.config/alacritty"
        "tmux:$HOME/.config/tmux"
        "yazi:$HOME/.config/yazi"
        "vimrc:$HOME/.vimrc"
        "vim:$HOME/.vim"
        ".tmux.conf:$HOME/.tmux.conf"
        ".zshrc:$HOME/.zshrc"
        ".luarc.json:$HOME/.luarc.json"
    )

    # Add i3 config if i3 is being installed
    if [ "$INSTALL_I3" = true ]; then
        configs+=("i3:$HOME/.config/i3")
    fi

    for config in "${configs[@]}"; do
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
        ln -s "$source_path" "$target"
        log_success "Symlink created for $source"
    done
}

# Function to setup Zsh as default shell
setup_zsh() {
    if [ "$SHELL" = "$(which zsh)" ]; then
        log_success "Zsh is already the default shell"
        return
    fi
    
    log_info "Setting up Zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Zsh set as default shell (will take effect on next login)"
}

# Function to setup SSH for key-only authentication
setup_ssh() {
    if [ "$ENABLE_SSH" != true ]; then
        log_info "SSH setup skipped (disabled in profile)"
        return
    fi

    log_info "Configuring SSH for key-only authentication..."
    
    # Enable and start SSH service
    sudo systemctl enable ssh
    sudo systemctl start ssh
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Backup original SSH config
    if [ -f "/etc/ssh/sshd_config" ]; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        log_info "SSH config backed up to /etc/ssh/sshd_config.backup"
    fi
    
    # Configure SSH daemon for key-only authentication
    sudo tee /etc/ssh/sshd_config.d/99-custom.conf > /dev/null <<EOF
# Custom SSH configuration for key-only authentication
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
EOF
    
    # Test SSH configuration
    if sudo sshd -t; then
        sudo systemctl restart ssh
        log_success "SSH configured for key-only authentication"
        log_warning "Remember to add your SSH public key to ~/.ssh/authorized_keys before logging out!"
    else
        log_error "SSH configuration test failed. Please check the configuration."
        return 1
    fi
}

# Function to setup sudo
setup_sudo() {
    log_info "Configuring sudo..."
    
    # Add current user to sudo group if not already there
    if groups "$USER" | grep -q '\bsudo\b'; then
        log_success "User $USER is already in sudo group"
    else
        log_info "Adding user $USER to sudo group..."
        sudo usermod -aG sudo "$USER"
        log_success "User $USER added to sudo group"
        log_warning "You may need to log out and back in for sudo group membership to take effect"
    fi
    
    # Configure sudo to not require password for a short time after first use
    if [ ! -f "/etc/sudoers.d/timestamp_timeout" ]; then
        echo "Defaults timestamp_timeout=15" | sudo tee /etc/sudoers.d/timestamp_timeout > /dev/null
        log_success "Sudo timeout configured (15 minutes)"
    fi
}

# Function to disable desktop environment and configure TTY boot
setup_headless_boot() {
    if [ "$ENABLE_GUI" = true ]; then
        log_info "Headless boot setup skipped (GUI enabled in profile)"
        return
    fi

    log_info "Configuring system for headless/TTY boot..."
    
    # Set default target to multi-user (console) instead of graphical
    sudo systemctl set-default multi-user.target
    log_success "Set default boot target to multi-user (TTY)"
    
    # Disable common display managers
    for dm in gdm3 lightdm sddm xdm; do
        if systemctl is-enabled "$dm" >/dev/null 2>&1; then
            sudo systemctl disable "$dm"
            log_success "Disabled display manager: $dm"
        fi
    done
    
    # Disable screen blanking/sleep on TTY
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    log_success "Disabled sleep/suspend/hibernate targets"
    
    # Disable console screen blanking via GRUB
    if grep -q "consoleblank=0" /etc/default/grub; then
        log_success "Console blanking already disabled in GRUB"
    else
        log_info "Disabling console screen blanking in GRUB..."
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet consoleblank=0"/' /etc/default/grub
        sudo update-grub
        log_success "Console screen blanking disabled in GRUB"
    fi
    
    log_info "System configured for TTY boot. Reboot to take effect."
}

# Function to setup i3 window manager
setup_i3wm() {
    if [ "$INSTALL_I3" != true ]; then
        log_info "i3 setup skipped (not enabled in profile)"
        return
    fi

    log_info "Configuring i3 window manager..."
    
    # Set default target to graphical
    sudo systemctl set-default graphical.target
    log_success "Set default boot target to graphical (GUI)"
    
    # Enable and configure lightdm
    sudo systemctl enable lightdm
    
    # Create lightdm config to auto-start i3
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    sudo tee /etc/lightdm/lightdm.conf.d/10-i3.conf > /dev/null <<EOF
[Seat:*]
autologin-user=$USER
autologin-session=i3
EOF
    
    # Create i3 session file if it doesn't exist
    if [ ! -f "/usr/share/xsessions/i3.desktop" ]; then
        sudo tee /usr/share/xsessions/i3.desktop > /dev/null <<EOF
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
Keywords=tiling;wm;windowmanager;window;manager;
EOF
    fi
    
    log_success "i3 window manager configured"
    log_info "System will boot into i3 automatically after reboot"
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_success "Oh My Zsh is already installed"
        return
    fi
    
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed"
}

# Function to setup .zshrc
setup_zshrc() {
    log_info "Setting up .zshrc..."
    
    # If we have a .zshrc in dotfiles, use it
    if [ -f "$DOTFILES_DIR/.zshrc" ]; then
        log_info "Found .zshrc in dotfiles, creating symlink..."
        if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
            log_info "Backed up existing .zshrc to .zshrc.backup"
        fi
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc symlinked from dotfiles"
    else
        log_warning "No .zshrc found in dotfiles directory"
    fi
}

# Main execution
main() {
    # Profile selection must be first
    select_profile
    
    log_info "Starting Debian 12 dotfiles setup with profile: $PROFILE"

    # Install system packages
    install_apt_packages
    
    # Setup sudo
    setup_sudo
    
    # Configure boot mode based on profile
    if [ "$ENABLE_GUI" = true ]; then
        setup_i3wm
    else
        setup_headless_boot
    fi

    # Install Flatpak
    install_flatpak
    
    # Install Flatpak packages
    install_flatpak_packages
    
    # Install Homebrew
    install_homebrew
    
    # Install Homebrew packages
    install_brew_packages
    
    # Install Snap packages (only for full installs with GUI)
    install_snap_packages
    
    # Install Oh My Zsh
    install_oh_my_zsh

    # Install TPM (Tmux Plugin Manager)
    install_tpm
    
    # Create symlinks
    create_symlinks
    
    # Setup .zshrc
    setup_zshrc
    
    # Setup Zsh as default shell
    setup_zsh
    
    # Setup SSH (only if enabled)
    setup_ssh
    
    log_success "Setup completed successfully with profile: $PROFILE"
    echo ""
    log_warning "IMPORTANT NEXT STEPS:"
    
    if [ "$ENABLE_SSH" = true ]; then
        log_warning "1. Add your SSH public key to ~/.ssh/authorized_keys"
        log_warning "2. Test SSH connection before logging out"
        log_info "   SSH public key should be added with: echo 'your-public-key' >> ~/.ssh/authorized_keys"
        log_info "   Then set proper permissions: chmod 600 ~/.ssh/authorized_keys"
    fi
    
    log_warning "3. Restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_warning "4. You may need to log out and back in for shell and group changes to take effect"
    
    if [ "$INSTALL_I3" = true ]; then
        log_warning "5. Reboot to start using i3 window manager"
        log_info "   After reboot, the system will automatically log in and start i3"
    elif [ "$ENABLE_GUI" = false ]; then
        log_warning "5. Reboot to switch to TTY-only mode"
    fi
    
    echo ""
    log_info "Profile Summary:"
    log_info "  Selected: $PROFILE"
    log_info "  Install level: $INSTALL_LEVEL"
    log_info "  SSH: $([ "$ENABLE_SSH" = true ] && echo "enabled" || echo "disabled")"
    log_info "  GUI: $([ "$ENABLE_GUI" = true ] && echo "enabled" || echo "disabled")"
    log_info "  i3wm: $([ "$INSTALL_I3" = true ] && echo "enabled" || echo "disabled")"
}

# Run main function
main "$@"
