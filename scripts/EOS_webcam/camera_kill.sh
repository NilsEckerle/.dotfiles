#!/usr/bin/env bash

if [[ -f ~/.camera_process.pid ]]; then
    kill "$(cat ~/.camera_process.pid)" 2>/dev/null || true
    rm ~/.camera_process.pid
fi

# Kill any stray ffmpeg writing to v4l2
pkill -f "ffmpeg.*v4l2" 2>/dev/null || true

sudo modprobe -r v4l2loopback
