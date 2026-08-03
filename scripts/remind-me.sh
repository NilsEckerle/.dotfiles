#!/usr/bin/env bash
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export WAYLAND_DISPLAY="wayland-1"

# 1. Locked -> skip
[[ "$(hyprctl locked)" == "true" ]] && exit 1

# 2. Currently away (idle) -> skip
[[ -f /tmp/.away ]] && exit 2

# 3. Just came back -> skip if resumed < 20 min ago
min_seated=20
if [[ -f /tmp/.last_resume ]]; then
    seated=$(( $(date +%s) - $(cat /tmp/.last_resume) ))
    (( seated < (min_seated*60) )) && exit 3
fi

notify-send "$1"
exit 0
