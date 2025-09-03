#!/bin/bash
mkdir -p /tmp

echo "Starting GPU monitor using radeontop..."

while true; do
  gpu_usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null)

  if [ -n "$gpu_usage" ]; then
    echo "${gpu_usage}%" > /tmp/gpu_usage
    echo "$(date): GPU Usage: ${gpu_usage}%"
  else
    echo "N/A" > /tmp/gpu_usage
    echo "$(date): GPU Usage: N/A ('cat /sys/class/drm/card0/device/gpu_busy_percent' failed)"
  fi

  sleep 2
done
