# ----- $PATH ----- #
#####################
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/home/nils/.local/share/bob/nvim-bin"
export PATH="$PATH:/usr/share/dotnet"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
# ----- What OS are we running? ----- #
# MacOS
if [[ $(uname) == "Darwin" ]]; then
    # add sdl2 to $Path
    export LIBRARY_PATH="$LIBRARY_PATH:/opt/homebrew/lib"
    export PATH="$PATH:/opt/homebrew/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin/brew"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ----- oh-my-zsh ----- #
#########################
source $ZSH/oh-my-zsh.sh
plugins=(git)
ZSH_THEME="robbyrussell"
PROMPT="%F{1}%m%f%B|%b%F{6}%n%f %B%F{45}%~%f%b%F{1} > %f"

autoload -Uz vcs_info
precmd() { vcs_info }

# Format for Git branch and pull/push status
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%f %F{green}%a%f'
zstyle ':vcs_info:*' enable git

# Prompt with Git branch and diff
PROMPT='%F{1}%m%f|%F{6}%n%f %F{45}%~%f%b %F{yellow}${vcs_info_msg_0_}%f ${GIT_REMOTE_STATUS}
%F{1} > %f'

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
alias fr="$HOME/scripts/switch_repo.sh"
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
alias act="source .env/bin/activate"
# Godot
alias godot_run='nohup Godot_v4.3-stable_mono_linux.x86_64 > /dev/null 2>&1 &'
alias godot='nohup Godot_v4.3-stable_mono_linux.x86_64 -e > /dev/null 2>&1 &'



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
    tmux attach -t TMUX || tmux a -t Default || $HOME/scripts/tmux_create_default.sh
fi

# Welcoming info
# echo "brew version running: `which brew`, `brew --version`"
if command -v figlet >/dev/null 2>&1; then
    # basename "$PWD" | figlet -t # print only the folder
    pwd | figlet -t # print the path
fi


# eval SSH_AUTH_SOCK=/tmp/ssh-XXXXXXd7Iv7N/agent.139110; export SSH_AUTH_SOCK;
# SSH_AGENT_PID=139111; export SSH_AGENT_PID;
# alias switch_brew_x86="arch -x86_64 /usr/local/bin/brew; echo 'brew version running: `which brew`, `brew --version`\nsystem archetecture: `arch`'"
# alias switch_brew_arm="arch -arm64  /opt/homebrew/bin/brew; echo 'brew version running: `which brew`, `brew --version`\nsystem archetecture: `arch`'"
export EDITOR=nvim
export PATH="$HOME/Applications/tdf/target/release:$PATH"
export PATH="$HOME/GodotMono:$PATH"
