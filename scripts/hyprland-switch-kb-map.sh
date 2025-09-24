#!/bin/bash

KEYMAP=$1
HYPRLAND_CONFIG=$HOME/.config/hypr/hyprland.conf

# Check if keymap argument is provided
if [ -z "$KEYMAP" ]; then
    echo "Usage: $0 <keymap>"
    echo "Example: $0 de"
    exit 1
fi

# Check if config file exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Error: Hyprland config file not found at $HYPRLAND_CONFIG"
    exit 1
fi

# Replace kb_layout line using sed
sed -i "s/^[[:space:]]*kb_layout[[:space:]]*=[[:space:]]*[^[:space:]]*/  kb_layout = $KEYMAP/" "$HYPRLAND_CONFIG"

echo "Keyboard layout updated to: $KEYMAP"
