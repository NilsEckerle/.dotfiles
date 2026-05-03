#!/usr/bin/env sh
sudo pacman -Syu "$@" --needed --noconfirm
if [ $? -eq 1 ]; then
    yay -Syu "$@" --needed --noconfirm
fi
