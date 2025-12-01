#!/usr/bin/env bash

# Handle mouse clicks
case $BLOCK_BUTTON in
    1) firefox --new-window https://calendar.proton.me/ ;;
    3) alacritty --command neomutt ;;
esac

echo $(date '+%Y-%m-%d - %H:%M')

