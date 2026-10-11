#!/usr/bin/env bash

# Get one line of radeontop output
output=$(radeontop -b 3 -d - -l 1 | tail -n 1)

# Extract VRAM usage percentage
vram_percent=$(echo "$output" | grep -oP 'vram \K[0-9]+')

echo "${vram_percent}"
