#!/usr/bin/env bash

# Get one line of radeontop output
output=$(radeontop -b 3 -d - -l 1 | tail -n 1)

# Extract values using grep and awk
gpu_usage=$(echo "$output" | grep -oP 'gpu \K[0-9]+')
# vram_percent=$(echo "$output" | grep -oP 'vram \K[0-9]+')
# vram_mb=$(echo "$output" | grep -oP 'vram [0-9.]+% \K[0-9]+')
# gtt_percent=$(echo "$output" | grep -oP 'gtt \K[0-9]+')
# gtt_mb=$(echo "$output" | grep -oP 'gtt [0-9.]+% \K[0-9]+')
# mclk_percent=$(echo "$output" | grep -oP 'mclk \K[0-9]+')
# mclk_ghz=$(echo "$output" | grep -oP 'mclk [0-9.]+% \K[0-9.]+')
# sclk_percent=$(echo "$output" | grep -oP 'sclk \K[0-9]+')
# sclk_ghz=$(echo "$output" | grep -oP 'sclk [0-9.]+% \K[0-9.]+')

# Print variables
echo "${gpu_usage}"
# echo "GPU Usage: ${gpu_usage}%"
# echo "VRAM Usage: ${vram_mb}MB (${vram_percent}%)"
# echo "GTT Usage: ${gtt_mb}MB (${gtt_percent}%)"
# echo "Memory Clock: ${mclk_ghz}GHz (${mclk_percent}%)"
# echo "Shader Clock: ${sclk_ghz}GHz (${sclk_percent}%)"
