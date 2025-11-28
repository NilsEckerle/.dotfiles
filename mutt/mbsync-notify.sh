#!/bin/bash

MAILDIR="$HOME/Mail/INBOX/new"
NOTIFY_SCRIPT="$HOME/.config/mutt/notify-email.sh"
LAST_CHECK="$HOME/.cache/mutt-notifications/last-check"

mkdir -p "$(dirname "$LAST_CHECK")"

if [ -f "$LAST_CHECK" ]; then
    REFERENCE="$LAST_CHECK"
else
    REFERENCE="/tmp/mutt-first-run-$$"
    touch -d "1 hour ago" "$REFERENCE"
fi

if [ -d "$MAILDIR" ]; then
    find "$MAILDIR" -type f -newer "$REFERENCE" 2>/dev/null | while read -r mail; do
        if [ -f "$mail" ]; then
            cat "$mail" | "$NOTIFY_SCRIPT"
        fi
    done
fi

touch "$LAST_CHECK"
