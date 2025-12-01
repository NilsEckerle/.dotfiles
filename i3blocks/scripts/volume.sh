#!/usr/bin/env bash
# Volume control script for i3blocks
# Matches Waybar pulseaudio format: icon + volume%

# Get volume and mute status
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1)
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')

# Handle mouse clicks
case $BUTTON in
    1) kitty pulsemixer ;;  # Left click - open pulsemixer
    3) kitty sh -c 'tmux new-session rmpc' ;;  # Right click - open music player
esac

# Display volume with icon
if [ "$muted" = "yes" ]; then
    echo ""  # Muted icon
else
    if [ "$volume" -ge 70 ]; then
        icon=" "
    elif [ "$volume" -ge 40 ]; then
        icon=" "
    else
        icon=""
    fi
    echo "$icon $volume%"
fi

