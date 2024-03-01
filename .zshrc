# ----- alias ----- #
#####################
alias ll='ls -la'
alias c='clear'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# ----- oh-my-zsh ----- #
#########################
source $ZSH/oh-my-zsh.sh
plugins=(git)

# ----- $PATH ----- #
#####################
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# ----- zoxide ----- #
######################
eval "$(zoxide init --cmd cd zsh)"

# ----- What OS are we running? ----- #
#######################################
# MacOS
if [[ $(uname) == "Darwin" ]]; then
  # add sdl2 to $Path
  export PATH="/opt/homebrew/opt/sdl2:$PATH"
