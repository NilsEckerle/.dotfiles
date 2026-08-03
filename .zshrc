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
# .net
export PATH="$PATH:/home/nils/.dotnet/tools"
# go
export PATH=$PATH:/usr/lib/qt6/bin
# qt6
export PATH=$PATH:$HOME/go/bin
# export PATH="$PATH:$HOME/.dotfiles/scripts/latex-utils"
export PATH="$PATH:/snap/bin"
export PATH="$PATH:$HOME/scripts"

# ----- Oh-My-Zsh Configuration ----- #
######################################
ZSH_THEME="robbyrussell"
plugins=(
	git
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_STRATEGY=(history completion) # Autosuggestions configuration
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh  Source the plugin
bindkey '^Y' autosuggest-accept # Bind Ctrl+Y to accept suggestion

# Custom Prompt ----- #
# Load version control info
autoload -Uz vcs_info
precmd() { vcs_info }

# Format for Git branch and status
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%f %F{green}%a%f'
zstyle ':vcs_info:*' enable git

# Custom prompt with Git information
PROMPT='%F{1}%m%f|%F{6}%n%f %F{45}%3~%f%b %F{yellow}${vcs_info_msg_0_}%f ${GIT_REMOTE_STATUS}
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

# ----- Git Tools ----- #
#########################
eval "$(wtp shell-init zsh)"

# ----- Aliases ----- #
#######################
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
# alias go='git switch'
alias gamend='git commit --amend'
alias lg='lazygit'
alias gitclip='(echo "# Git Commit Analysis

**Task**: Create focused, atomic commits commands for the terminal.

**Requirements**:
- Each commit should address ONE specific change (atomic commits)
- Group related changes logically (e.g., feature additions, bug fixes, refactoring, documentation)
- Use conventional commit format: type(scope): description
- Keep commit messages concise but descriptive (50 chars max for subject)

**Output Format**:
1. Nothing but a code block with all commands combined
2. Do not use chunk commits

**Example Output**:
\`\`\`bash
# Commit 1: Add user authentication
git add src/auth.js src/middleware/auth.js
git commit -m \"feat(auth): add JWT token validation\"
\`\`\`

**Git Status, Diff and Untracked**:" && echo "" && gs && git --no-pager diff && git_changes.sh)'
alias gitclipai='gitclip | wl-copy'
alias gitclipweb='gitclip | wl-copy -t text/plain && xdg-open https://claude.ai/new > /dev/null 2>&1'
context() {
  tree -L 3 -I 'build|.git|node_modules'

  # Markdown: nur Headings (README etc.)
  for f in $(find . -maxdepth 2 -iname 'readme*.md'); do
    echo "\n=== $f ==="
    grep -E '^#{1,3} ' "$f"
  done

  # C/C++: nur Header-Dateien, daraus Klassen/Structs/Funktionsdeklarationen
  for f in $(find . -maxdepth 3 -name '*.h' -o -name '*.hpp' | head -20); do
    echo "\n=== $f ==="
    grep -E '^\s*(class|struct|namespace|enum)\s|^\s*[A-Za-z_].*\(.*\)\s*(const)?\s*;' "$f" | head -30
  done

  # Go: nur Signaturen (func/type), keine Bodies
  for f in $(find . -maxdepth 3 -name '*.go' ! -name '*_test.go' | head -15); do
    echo "\n=== $f ==="
    grep -E '^(func|type)\s+[A-Z]' "$f" | head -15
  done

  # LaTeX: nur Struktur (chapter/section/label/caption), keine Bodies
  for f in $(find . -maxdepth 3 -name '*.tex' | head -15); do
    echo "\n=== $f ==="
    grep -E '\\\\(chapter|section|subsection|subsubsection|label|caption)\{' "$f" | head -20
  done
}

ai() {
  {
    context
    echo "\nFrage: $*"
    echo "Hinweis: Antworte auf die Frage. Wenn dir Kontext fehlt, nenne konkret, welche Datei oder welchen Abschnitt du sehen musst."
  } | docker exec -i ollama ollama run qwen2.5-coder:14b
}

goose() {
  local here="$PWD"
  (cd ~/Documents/local-ai-setup && \
   docker compose run --rm -v "$here:/work:ro" -w /work goose "$@")
}

#useful
alias ltxtemplate='latex_template.sh'
alias kb=hyprland-switch-kb-map.sh
ytdl() {
  yt-dlp \
    --extract-audio \
    --audio-format opus \
    --audio-quality 0 \
    --embed-thumbnail \
    --embed-metadata \
    --parse-metadata "%(title)s:%(meta_title)s" \
    --parse-metadata "%(uploader)s:%(meta_artist)s" \
    --output "%(playlist_index)02d - %(title)s.%(ext)s" \
    "$@"
}

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

# kagari
alias kagaridoc="ssh nils@kagari 'cd ~/docs && make' && scp nils@kagari:~/docs/kagari-server-doc.html /tmp/ && librewolf /tmp/kagari-server-doc.html"

#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# eval "$(/opt/homebrew/bin/brew shellenv)"

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


## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/nils/.config/.dart-cli-completion/zsh-config.zsh ]] && . /home/nils/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

alias rss=newsboat
