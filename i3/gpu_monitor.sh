#!/bin/bash
# Simple GPU Monitor using radeontop
mkdir -p /tmp

if ! command -v radeontop >/dev/null 2>&1; then
  echo "radeontop not found. Install with: sudo pacman -S radeontop"
  exit 1
fi

echo "Starting GPU monitor using radeontop..."

gpu_usage=$(timeout 3s radeontop -d - -l 1 2>/dev/null | \
  grep -oP 'gpu \K[0-9]+(?=\.[0-9]+%)' | head -1)

if [ -n "$gpu_usage" ]; then
  echo "${gpu_usage}%" > /tmp/gpu_usage
  echo "$(date): GPU Usage: ${gpu_usage}%"
else
  echo "N/A" > /tmp/gpu_usage
  echo "$(date): GPU Usage: N/A (radeontop failed)"
fi

sleep 2
