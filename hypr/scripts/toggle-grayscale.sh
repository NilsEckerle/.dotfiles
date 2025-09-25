#!/bin/bash
mkdir -p ~/.config/hypr/scripts

current_shader=$(hyprctl getoption decoration:screen_shader | grep "str:" | sed 's/.*str: //')
echo $current_shader

if [ "$current_shader" = "[[EMPTY]]" ] || [ -z "$current_shader" ]; then
    hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/grayscale.frag
    notify-send "Grayscale ON"
else
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
    notify-send "Grayscale OFF"
fi
