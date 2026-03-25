#!/usr/bin/env bash
set -euo pipefail

# Toggle simple del menú de portapapeles con rofi:
# - Si hay una instancia de rofi abierta (típicamente la del clipboard), la cierra.
# - Si no, abre el menú para elegir un elemento de cliphist y lo copia con wl-copy.

ROFI_NAME="cliphist-clipboard"

if pgrep -f "rofi.*-name[[:space:]]*${ROFI_NAME}" > /dev/null; then
  pkill -f "rofi.*-name[[:space:]]*${ROFI_NAME}" || true
  exit 0
fi

# Muestra lista de historial, el usuario elige un elemento,
# lo decodificamos y lo copiamos al clipboard de Wayland.
cliphist list \
  | rofi -dmenu -name "${ROFI_NAME}" \
  | cliphist decode \
  | wl-copy

