#!/bin/bash
while true; do
    if ! pgrep -x hyprpaper > /dev/null; then
        hyprpaper &
    fi
    sleep 5
done
