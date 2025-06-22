#!/bin/bash
repo_path=$1
tmux_session=$2
echo $repo_path
tmux new-session -d -s "$tmux_session" -c "$repo_path" -n "iamb" "iamb -C .config"
tmux new-window -t "$tmux_session" -n "zsh" -c "$repo_path"
tmux select-window -t "$tmux_session:0"
