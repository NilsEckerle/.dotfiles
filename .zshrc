# ----- $PATH ----- #
#####################
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/home/nils/.local/share/bob/nvim-bin"
export PATH="$PATH:/usr/share/dotnet"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
export PATH="$PATH:/opt/homebrew/bin/brew"
eval "$(/opt/homebrew/bin/brew shellenv)"
# ----- What OS are we running? ----- #
# MacOS
if [[ $(uname) == "Darwin" ]]; then
  # add sdl2 to $Path
  export LIBRARY_PATH="$LIBRARY_PATH:/opt/homebrew/lib"
fi

# ----- oh-my-zsh ----- #
#########################
source $ZSH/oh-my-zsh.sh
plugins=(git)
ZSH_THEME="nilse-theme"
PROMPT="%F{1}%m%f%B|%b%F{6}%n%f %B%F{45}%~%f%b%F{1} > %f"

# ----- zoxide ----- #
######################
eval "$(zoxide init --cmd z zsh)"
function cd() {
  if [[ "$1" == "--" ]]; then
    builtin cd "$@"
  else
    z "$@" || builtin cd "$@"
  fi
}

function repo_tmux {
    filter_params=""
    dirs_to_find_in=("$HOME/Documents")
    
    # Apply filter if an argument is provided
    if [ -n "$1" ]; then
        filter_params="-q $1"
    fi
    
    # Find the repository path
    repo_path=$(find "${dirs_to_find_in[@]}" -name .git -type d -prune -maxdepth 5 | \
      sed 's/\/.git$//' | \
      awk -F'/' '{print $NF "\t" $0}' | \
      fzf --with-nth=1 --delimiter="\t" $filter_params --select-1 | \
      cut -f2)

    if [ -z "$repo_path" ]; then
      tmux_session="Default"
        # echo "No repository selected."
        if tmux has-session -t "$tmux_session" 2>/dev/null; then
            echo "Tmux session '$tmux_session' already exists. Switching..."
            tmux switch-client -t "$tmux_session"
        else
            # Create a new tmux session
            tmux new-session -d -s "$tmux_session" -c "$repo_path" -n "yazi" "yazi $repo_path"
            tmux new-window -t "$tmux_session" -n "zsh" -c "$repo_path"
            tmux select-window -t "$tmux_session:0"
            
            # Attach to the tmux session if not already in tmux
            if [ -z "$TMUX" ]; then
                tmux attach-session -t "$tmux_session"
            else
                # If already in tmux, switch to the session
                tmux switch-client -t "$tmux_session"
            fi
        fi
        return 1
    fi
    
    repo_name=$(basename "$repo_path")
    tmux_session="repo_${repo_name}"
    
    # Check if the session already exists
    if tmux has-session -t "$tmux_session" 2>/dev/null; then
        echo "Tmux session '$tmux_session' already exists. Switching..."
        tmux switch-client -t "$tmux_session"
    else
        # Create a new tmux session
        tmux new-session -d -s "$tmux_session" -c "$repo_path" -n "yazi" "yazi $repo_path"
        tmux new-window -t "$tmux_session" -n "zsh" -c "$repo_path"
        tmux select-window -t "$tmux_session:0"
        
        # Attach to the tmux session if not already in tmux
        if [ -z "$TMUX" ]; then
            tmux attach-session -t "$tmux_session"
        else
            # If already in tmux, switch to the session
            tmux switch-client -t "$tmux_session"
        fi
    fi
}

# ----- alias ----- #
#####################
# overall
alias ll='ls -la'
alias c='clear'
alias pdf='tdf'
alias y='yazi'
alias yh='yazi ~/'
# git
alias lg='lazygit'
alias github='eval `ssh-agent`; ssh-add ~/.ssh/github'
alias fr="repo_tmux"
# nvim
alias v='nvim'
alias v.='nvim .'
alias n='nvim'
alias n.='nvim . '
alias nvim.='nvim . '
# help
alias help='selected_command=$(tldr -l | fzf --preview "tldr -C {1}" --preview-window=right,70%); tldr -C "$selected_command"'
alias helpman='selected_command=$(man -k . | awk "{split(\$0, a, \"(\"); print a[1]}" | fzf --preview "man {1}" --preview-window=right,70%); man "$selected_command"'
# Python
alias env_create="python3 -m venv env"
alias ack="source env/bin/activate"

# # ----- MacOS GamePortingToolKit ----- #
# ########################################
# GAME_PORTING_TOOL_KIT_ENABLED=true
# GAME_PORTING_TOOL_KIT_ENABLED=false
# if [[ $(uname) == "Darwin" ]]; then
#   # MACOS CONFIG
#   if  [[ $GAME_PORTING_TOOL_KIT_ENABLED == true ]]; then
#     eval "$(/usr/local/bin/brew shellenv)"
#   else
#     eval "$(/opt/homebrew/bin/brew shellenv)"
#   fi
# else
#   # LINUX CONFIG
#   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# fi


# # ----- tmux ----- #
# ######################
if [ -z "$TMUX" ]
then
    tmux attach -t TMUX || fr
fi

# Welcoming info
echo ""
echo "brew version running: `which brew`, `brew --version`"
nerdfetch
echo ""


# eval SSH_AUTH_SOCK=/tmp/ssh-XXXXXXd7Iv7N/agent.139110; export SSH_AUTH_SOCK;
# SSH_AGENT_PID=139111; export SSH_AGENT_PID;
# alias switch_brew_x86="arch -x86_64 /usr/local/bin/brew; echo 'brew version running: `which brew`, `brew --version`\nsystem archetecture: `arch`'"
# alias switch_brew_arm="arch -arm64  /opt/homebrew/bin/brew; echo 'brew version running: `which brew`, `brew --version`\nsystem archetecture: `arch`'"
