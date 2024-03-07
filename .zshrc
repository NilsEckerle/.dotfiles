# ----- alias ----- #
#####################
alias ll='ls -la'
alias c='clear'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# ----- $PATH ----- #
#####################
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# ----- What OS are we running? ----- #
# MacOS
if [[ $(uname) == "Darwin" ]]; then
  # add sdl2 to $Path
  export PATH="/opt/homebrew/opt/sdl2:$PATH"
fi

# ----- oh-my-zsh ----- #
#########################
source $ZSH/oh-my-zsh.sh
plugins=(git)
ZSH_THEME="nilse-theme"
PROMPT="%F{1}%m%f%B|%b%F{6}%n%f %B%F{45}%~%f%b%F{1} > %f"

# ----- zoxide ----- #
######################
eval "$(zoxide init --cmd cd zsh)"

# ----- Homebrew ----- #
########################
if [[ $(uname) == "Linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ----- ssh-agent ----- #
#########################
eval `ssh-agent`
eval `ssh-add ~/.ssh/github`

