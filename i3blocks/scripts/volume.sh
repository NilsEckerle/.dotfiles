#!/usr/bin/env bash
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1)
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes')

# Handle mouse clicks
case $BLOCK_BUTTON in
    1) alacritty --command pulsemixer ;;  # Left click - open pulsemixer
    3) alacritty --command rmpc ;;  # Right click - open music player
esac

if [ "$muted" = "yes" ]; then
    echo " "  # Muted icon
else
    if [ "$volume" -ge 70 ]; then
        icon=" "
    elif [ "$volume" -ge 40 ]; then
        icon=" "
    else
        icon=" "
    fi
    echo "$icon $volume%"
fi

