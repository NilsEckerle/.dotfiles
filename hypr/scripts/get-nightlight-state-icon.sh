#!/usr/bin/env bash

# Check if hyprsunset is running
if pgrep -x hyprsunset > /dev/null; then
    # Night light is ON (5000K) - show warm/orange icon
    echo '󰛨'
else
    # Night light is OFF (6000K) - show normal/gray icon
    echo '󰌵'
fi
