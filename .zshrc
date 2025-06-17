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
export PATH="$PATH:$HOME/.dotfiles/scripts/latex-utils"

# ----- Oh-My-Zsh Configuration ----- #
######################################
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Custom Prompt ----- #
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
alias todo='nvim ~/Documents/.todo.md'

# Editors
alias n='nvim'
alias n.='nvim . '

# Documentation & Help
alias help='selected_command=$(tldr -l | fzf --preview "tldr -C {1}" --preview-window=right,70%); tldr -C "$selected_command"'
alias helpman='selected_command=$(man -k . | awk "{split(\$0, a, \"(\"); print a[1]}" | fzf --preview "man {1}" --preview-window=right,70%); man "$selected_command"'

# Python
alias env_create="python3 -m venv .env"
alias act="source .env/bin/activate"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ----- Tmux Auto-Start ----- #
##############################
if [ -z "$TMUX" ]; then
    tmux attach -t TMUX || tmux
fi

# ----- Welcome Message ----- #
##############################
if command -v figlet >/dev/null 2>&1; then
    pwd | figlet -t  # Print the current path
fi
