#!/usr/bin/env bash

OPENWEBUI_CLASS="chrome-localhost__-openwebui"

# Check if Open WebUI window exists
CLIENT=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$OPENWEBUI_CLASS\") | .address" | head -n1)

if [ -z "$CLIENT" ]; then
    chromium --app=http://localhost:8080/ --class=openwebui --profile-directory=openwebui &
else
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$CLIENT"
    hyprctl dispatch focuswindow "address:$CLIENT"
fi
