#!/bin/bash
choice=$(echo -e "Calculator\nColor Picker" | wofi --dmenu --prompt "Select Tool:" --width 15%)

case "$choice" in
    "Calculator")
        ~/.dotfiles/scripts/calculator/calc-wrapper.sh --dmenu
        ;;
    "Color Picker")
        hyprpicker -an
        ;;
esac
