#!/bin/bash

case "$1" in
    "")
        # No argument - launch TUI
        # kitty -e /home/nils/scripts/calculator/env/bin/python /home/nils/scripts/calculator/calc.py
        kitty -o close_on_child_death=yes -e /home/nils/scripts/calculator/env/bin/python /home/nils/scripts/calculator/calc.py
        ;;
    "--dmenu")
        # Dmenu mode for quick calculation
        expression=$(echo "" | wofi --dmenu --prompt "Calculate: ")
        if [ -n "$expression" ]; then
            result=$(/home/nils/scripts/calculator/env/bin/python /home/nils/scripts/calculator/calc.py "$expression")
            printf "%s" "$result" | wl-copy --type text/plain
            notify-send "Calculator" "Result: $result (copied to clipboard)"
        fi
        ;;
    *)
        # Direct calculation from command line
        /home/nils/scripts/calculator/env/bin/python /home/nils/scripts/calculator/calc.py "$@"
        ;;
esac
