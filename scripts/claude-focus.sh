#!/usr/bin/env bash

CLAUDE_CLASS="chrome-claude.ai__-claude"

# Check if claude window exists
CLIENT=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLAUDE_CLASS\") | .address" | head -n1)

if [ -z "$CLIENT" ]; then
    # Not running, launch it
    chromium --app=https://claude.ai --class=claude --profile-directory=claude &
else
    # Move it to current workspace
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$CLIENT"
    hyprctl dispatch focuswindow "address:$CLIENT"
fi
