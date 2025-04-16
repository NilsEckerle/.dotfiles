# ----- Environment Variables ----- #
################################
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Editor setting
export EDITOR=nvim

# ----- PATH Configuration ----- #
#################################
# Base PATH additions
export PATH="$PATH:$HOME/.local/share/bob/nvim-bin"
export PATH="$PATH:/usr/share/dotnet"
export PATH="$PATH:$HOME/Applications/tdf/target/release"
export PATH="$PATH:$HOME/GodotMono"
export PATH="$PATH:$HOME/.dotfiles/scripts/latex-utils"

# Package config
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH

# ----- OS-Specific Configuration ----- #
########################################
if [[ $(uname) == "Darwin" ]]; then
    # macOS specific settings
    export LIBRARY_PATH="$LIBRARY_PATH:/opt/homebrew/lib"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    # Linux specific settings
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ----- Oh-My-Zsh Configuration ----- #
######################################
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ----- Custom Prompt ----- #
############################
# Load version control info
autoload -Uz vcs_info
precmd() { vcs_info }

# Format for Git branch and status
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%f %F{green}%a%f'
zstyle ':vcs_info:*' enable git

# Custom prompt with Git information
PROMPT='%F{1}%m%f|%F{6}%n%f %F{45}%~%f%b %F{yellow}${vcs_info_msg_0_}%f ${GIT_REMOTE_STATUS}
%F{1} > %f'

# ----- Zoxide (Smart Directory Navigation) ----- #
##################################################
eval "$(zoxide init --cmd z zsh)"
function cd() {
  if [[ "$1" == "--" ]]; then
    builtin cd "$@"
  else
    z "$@" || builtin cd "$@"
  fi
}

# ----- Aliases ----- #
######################
# File Management
alias ll='ls -la'
alias c='clear'
alias y='yazi'
alias yh='yazi ~/'

# Git
alias lg='lazygit'
alias github='eval `ssh-agent`; ssh-add ~/.ssh/github'
alias fr="$HOME/scripts/switch_repo.sh"

# Editors
alias v='nvim'
alias v.='nvim .'
alias n='nvim'
alias n.='nvim . '
alias nvim.='nvim . '

# Documentation & Help
alias help='selected_command=$(tldr -l | fzf --preview "tldr -C {1}" --preview-window=right,70%); tldr -C "$selected_command"'
alias helpman='selected_command=$(man -k . | awk "{split(\$0, a, \"(\"); print a[1]}" | fzf --preview "man {1}" --preview-window=right,70%); man "$selected_command"'

# Python
alias env_create="python3 -m venv .env"
alias act="source .env/bin/activate"

# PDF Viewing
alias pdf='tdf'

# Godot
alias godot_run='nohup Godot_v4.3-stable_mono_linux.x86_64 > /dev/null 2>&1 &'
alias godot='nohup Godot_v4.3-stable_mono_linux.x86_64 -e > /dev/null 2>&1 &'

# ----- Tmux Auto-Start ----- #
##############################
if [ -z "$TMUX" ]; then
    tmux attach -t TMUX || tmux a -t Default || $HOME/scripts/tmux_create_default.sh
fi

# ----- Welcome Message ----- #
##############################
if command -v figlet >/dev/null 2>&1; then
    pwd | figlet -t  # Print the current path
fi
