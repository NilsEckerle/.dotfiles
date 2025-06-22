#!/bin/bash
tmux_session="Default"
if tmux has-session -t "$tmux_session" 2>/dev/null; then
  # Attach to the tmux session if not already in tmux
  if [ -z "$TMUX" ]; then
    tmux attach-session -t "$tmux_session"
  else
    # If already in tmux, switch to the session
    tmux switch-client -t "$tmux_session"
  fi
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
