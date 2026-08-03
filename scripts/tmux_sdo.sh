#!/usr/bin/env sh
# usage: tmux_sdo.sh <command...>
cmd="$*"
session=$(tmux display-message -p '#{session_name}')
tmux list-panes -s -t "$session" -F '#{pane_id} #{pane_tty} #{pane_pid}' | while read -r pane tty shell_pid; do
  fg_pid=$(ps -t "${tty#/dev/}" -o pid=,stat= 2>/dev/null | awk '$2 ~ /\+/ {print $1; exit}')
  if [ -n "$fg_pid" ] && [ "$fg_pid" != "$shell_pid" ]; then
    kill -TERM "$fg_pid" 2>/dev/null
  fi
  tmux send-keys -t "$pane" C-u
  tmux send-keys -t "$pane" "$cmd" C-m
done
