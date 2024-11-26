#!/bin/bash
function repo_tmux {
  filter_params=""
  dirs_to_find_in=("$HOME/Documents" "$HOME/.dotfiles")

  # Apply filter if an argument is provided
  if [ -n "$1" ]; then
    filter_params="-q $1"
  fi

  # Find the repository path
  repo_path=$(find "${dirs_to_find_in[@]}" -name .git -type d -prune -maxdepth 5 |
    sed 's/\/.git$//' |
    awk -F'/' '{print $NF "\t" $0}' |
    fzf --with-nth=1 --delimiter="\t" $filter_params --select-1 |
    cut -f2)

  # check nothing selected
  if [ -z "$repo_path" ]; then
    tmux_session="Default"
    # echo "No repository selected."
    if tmux has-session -t "$tmux_session" 2>/dev/null; then
      # echo "Tmux session '$tmux_session' already exists. Switching..."
      tmux switch-client -t "$tmux_session"
    else
      $HOME/scripts/tmux_create_default.sh
    fi
    return 1
  fi

  repo_name=$(basename "$repo_path")
  tmux_session="repo_${repo_name}"
  tmux_session=${tmux_session/./}

  # Check if the session already exists
  if tmux has-session -t "$tmux_session" 2>/dev/null; then
    # echo "Tmux session '$tmux_session' already exists. Switching..."
    tmux switch-client -t "$tmux_session"
  else
    # Create a new tmux session
    tmux new-session -d -s "$tmux_session" -c "$repo_path" -n "yazi"
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
repo_tmux
