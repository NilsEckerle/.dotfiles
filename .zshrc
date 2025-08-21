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
export PATH="$PATH:/snap/bin"

# ----- Oh-My-Zsh Configuration ----- #
######################################
ZSH_THEME="robbyrussell"
plugins=(
	git
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_STRATEGY=(history completion) # Autosuggestions configuration
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Source the plugin
bindkey '^Y' autosuggest-accept # Bind Ctrl+Y to accept suggestion

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
###################################################
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
alias fr="$HOME/scripts/switch_repo.sh"

# Editors
alias n='nvim'
alias n.='nvim . '

# email
alias email='neomutt'
alias mail='neomutt'
alias m='neomutt'

# git
alias gs='git status'
alias ga='git add'
alias gd='git diff --color-words'
alias gc='git commit'
alias gp='git pull'
alias gP='git push'
alias gf='git fetch'
alias go='git switch'
alias gamend='git commit --amend'
alias lg='lazygit'
alias gitclip='(echo "# Git Commit Analysis

**Task**: Analyze the git status and diff below to create focused, atomic commits.

**Requirements**:
- Each commit should address ONE specific change (atomic commits)
- Group related changes logically (e.g., feature additions, bug fixes, refactoring, documentation)
- Use conventional commit format: type(scope): description
- Keep commit messages concise but descriptive (50 chars max for subject)

**Output Format**:
1. Brief analysis of what changes were detected
2. Individual code blocks for each recommended commit with staging commands
3. Final code block with all commands combined

**Example Output**:
\`\`\`bash
# Commit 1: Add user authentication
git add src/auth.js src/middleware/auth.js
git commit -m \"feat(auth): add JWT token validation\"
\`\`\`

**Git Status and Diff**:" && echo "" && gs && gd) | xclip -selection clipboard'

#git enhanced
alias gl='git log --oneline --graph --decorate -10'
alias gla='git log --oneline --graph --decorate --all'
alias gll='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(blue)%an%Creset %C(green)%cr%Creset %s %C(auto)%d%Creset" --abbrev-commit'

#git undo
alias gr='git reset'
alias grh='git reset --hard'

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

# Created by `pipx` on 2025-08-10 12:51:36
export PATH="$PATH:/home/nils/.local/bin"
