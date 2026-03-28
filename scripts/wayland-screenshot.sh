#!/usr/bin/env bash
OUTPUT_DIR="$HOME/Screenshots"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Freeze screen
wayfreeze & PID=$!
sleep .1

# Get selection
SELECTION=$(slurp 2>/dev/null)

# Kill wayfreeze
kill $PID 2>/dev/null

# Check if selection was canceled
if [ -z "$SELECTION" ]; then
    exit 0
fi

# Take screenshot and open in swappy
FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$SELECTION" - | swappy -f - -o "$FILENAME"

# Check if file was actually saved and send notification
if [ -f "$FILENAME" ]; then
    wl-copy < cat "$FILENAME"
    notify-send "Screenshot Saved" "Saved to: $FILENAME" -i "$FILENAME" -t 3000
else
    # File wasn't saved, check if swappy saved it with default name
    LATEST=$(ls -t "$OUTPUT_DIR"/screenshot-*.png 2>/dev/null | head -1)
    if [ -n "$LATEST" ]; then
        wl-copy < cat "$LATEST"
        notify-send "Screenshot Saved" "Saved to: $LATEST" -i "$LATEST" -t 3000
    fi
fi
