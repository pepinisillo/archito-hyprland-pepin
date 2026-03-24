#!/bin/bash
ADDR=$(hyprctl activewindow -j | jq -r '.address')
STATE="/tmp/hypr-solid-$ADDR"

if [ -f "$STATE" ]; then
    # Quitar override: la ventana vuelve a seguir hyprland.conf
    hyprctl dispatch setprop "address:$ADDR" opacity_override 0
    hyprctl dispatch setprop "address:$ADDR" opacity_inactive_override 0
    hyprctl dispatch setprop "address:$ADDR" noblur 0
    rm "$STATE"
else
    # Modo sólido: forzar opaco sin blur
    hyprctl dispatch setprop "address:$ADDR" opacity 1.0
    hyprctl dispatch setprop "address:$ADDR" opacity_override 1
    hyprctl dispatch setprop "address:$ADDR" opacity_inactive 1.0
    hyprctl dispatch setprop "address:$ADDR" opacity_inactive_override 1
    hyprctl dispatch setprop "address:$ADDR" noblur 1
    touch "$STATE"
fi
