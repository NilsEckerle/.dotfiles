#!/usr/bin/env bash

# Check if hyprsunset is running
if pgrep -x hyprsunset > /dev/null; then
    # If running, kill it (return to normal 6000K)
    killall hyprsunset
else
    # If not running, start it with 5000K
    hyprsunset -t 5000 &
fi
