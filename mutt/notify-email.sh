#!/usr/bin/env bash

# Mutt notification script for Hyprland with persistent notifications for aliases

# Configuration
ALIASES_FILE="$HOME/.config/mutt/aliases.env"
NOTIFICATION_IDS_DIR="$HOME/.cache/mutt-notifications"
mkdir -p "$NOTIFICATION_IDS_DIR"

#!/bin/bash
input=$(cat)
FROM=$(echo "$input" | sed -n 's/^From: //p' | head -1)
SUBJECT=$(echo "$input" | sed -n 's/^Subject: //p' | head -1)

# Extract email address from "Name <email@example.com>" format
FROM_EMAIL=$(echo "$FROM" | sed -n 's/.*<\(.*\)>.*/\1/p')
if [ -z "$FROM_EMAIL" ]; then
  FROM_EMAIL="$FROM"
fi

# Check if sender is in aliases
IS_ALIAS=false
if [ -f "$ALIASES_FILE" ]; then
  # Extract email addresses from aliases file
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

        # Extract email from alias line (format: alias name email)
        ALIAS_EMAIL=$(echo "$line" | awk '{print $3}')

        if [ "$FROM_EMAIL" = "$ALIAS_EMAIL" ]; then
          IS_ALIAS=true
          break
        fi
      done < "$ALIASES_FILE"
fi

# Determine notification urgency and timeout
if [ "$IS_ALIAS" = true ]; then
  URGENCY="critical"
  TIMEOUT=0  # Persistent notification (0 = never expire)
  EXPIRE_TIME=""
else
  URGENCY="normal"
  TIMEOUT=5000  # 5 seconds
  EXPIRE_TIME="-t $TIMEOUT"
fi

# Send notification based on notification daemon
if command -v mako >/dev/null 2>&1; then
  # Using mako (recommended for Hyprland)
  NOTIF_ID=$(makoctl history | jq -r '.data[0][0].id.data' 2>/dev/null || echo "$$")

  notify-send -u "$URGENCY" \
    -a "Mutt" \
    -i "mail-unread" \
    $EXPIRE_TIME \
    "New Email from $FROM_EMAIL" \
    "$SUBJECT"

    # Store notification ID if it's from an alias (for potential later dismissal)
    if [ "$IS_ALIAS" = true ]; then
      echo "$(date +%s):$FROM_EMAIL" >> "$NOTIFICATION_IDS_DIR/persistent.log"
    fi

  elif command -v dunst >/dev/null 2>&1; then
    # Using dunst
    notify-send -u "$URGENCY" \
      -a "Mutt" \
      -i "mail-unread" \
      $EXPIRE_TIME \
      "New Email from$FROM_EMAIL" \
      "$SUBJECT"

    echo "$SUBJECT"
    if [ "$IS_ALIAS" = true ]; then
      echo "$(date +%s):$FROM_EMAIL" >> "$NOTIFICATION_IDS_DIR/persistent.log"
    fi
  else
    # Fallback to basic notify-send
    notify-send "New Email from $FROM" "$SUBJECT"
fi
