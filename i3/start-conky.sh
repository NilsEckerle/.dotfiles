#!/bin/bash
sleep 2  # Wait for other components to load
/usr/bin/conky -c "$HOME/.config/conky/conky-clock.conf"
