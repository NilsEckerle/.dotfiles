#!/bin/bash

# Capture the selection with slurp
SELECTION=$(slurp)

# Check if selection was canceled (ESC was pressed)
if [ -z "$SELECTION" ]; then
    # User canceled, exit silently
    exit 0
fi

# Create a temporary file for the screenshot
FILE=$(mktemp -u --suffix=.png)

# Take the screenshot using the selection
grim -g "$SELECTION" "$FILE"

# Copy to clipboard
wl-copy < "$FILE"

NOTIFICATION_TEXT="Screenshot saved and copied to clipboard"
# Send a notification with a larger image preview
notify-send -i "$FILE" "Screenshot" "$NOTIFICATION_TEXT" --hint=string:x-canonical-private-synchronous:screenshot --hint=int:transient:1

# Print the filename
echo "$FILE"
