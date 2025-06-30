#!/bin/bash
# GPU Monitor - RX 7700S (discrete GPU)

mkdir -p /tmp

while true; do
    # Monitor card0 (discrete RX 7700S)
    if [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
        gpu_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null)
        echo "${gpu_usage:-0}%" > /tmp/gpu_usage
    else
        echo "N/A" > /tmp/gpu_usage
    fi
    
    sleep 2
done
