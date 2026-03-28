#!/usr/bin/env bash

# ---------- CONFIG ----------

TIME_IN_HOURS=2

# ----------------------------

PIDFILE="/tmp/idle-inhibit.pid"
STARTFILE="/tmp/idle-inhibit.start"
TIME_IN_MINUTES=$((TIME_IN_HOURS * 60))
TIME_IN_SECONDS=$((TIME_IN_MINUTES* 60)) # This is used to inhibit time

case "$1" in
    toggle)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
            kill "$(cat $PIDFILE)"
            rm -f "$PIDFILE" "$STARTFILE"
        else
            date +%s > "$STARTFILE"
            systemd-inhibit --what=idle --who="Waybar" --why="Manually inhibited" sleep $TIME_IN_SECONDS &
            echo $! > "$PIDFILE"
        fi
        pkill -RTMIN+9 waybar
        ;;
    status)
        if [ -f "$PIDFILE" ] && kill -0 "$(cat $PIDFILE)" 2>/dev/null; then
            START=$(cat "$STARTFILE")
            NOW=$(date +%s)
            ELAPSED=$(( NOW - START ))
            REMAINING=$(( $TIME_IN_SECONDS - ELAPSED ))
            MINS=$(( REMAINING / 60 ))
            SECS=$(( REMAINING % 60 ))
            echo "<span color=\"#8ec07c\">󰒳  ${MINS}m</span>"
        else
            echo "<span color=\"#928374\">󰒲</span>"
        fi
        ;;
esac
