# .dotfiles

A collection of my personal dotfiles for configuring various development tools
and environments on debian. This repository contains configurations for terminal
emulators, window managers, text editors, and more.

## Debian version used and tested

Debian 12.11.0 amd64

## What's Inside

- **Terminal Emulators**
  - Alacritty
  - Kitty (with Gruvbox theme)

- **Window Manager**
  - i3 (with compton and i3blocks)

- **Text Editors**
  - Neovim (extensive configuration with plugins)
  - Vim (with Gruvbox colorscheme)

- **File Manager**
  - Yazi

- **LaTeX Templates**
  - Standard project template

- **Scripts**
  - Repository switching utility
  - Tmux session management
  - OS-specific setup scripts

## Installation

### Install debian

### Clone the Repository

```bash
git clone https://github.com/NilsEckerle/.dotfiles.git ~/.dotfiles
```

### Start the Setup

```bash
cd ~/.dotfiles
git switch debian-headless
./setup-scripts/debian-headless.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
