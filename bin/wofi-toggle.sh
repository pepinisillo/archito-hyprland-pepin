#!/usr/bin/env bash
set -euo pipefail

ROFI_NAME="app-launcher"
THEME="$HOME/.config/rofi/hypr-blue.rasi"

if pgrep -f "rofi.*-name[[:space:]]*${ROFI_NAME}" > /dev/null; then
    pkill -f "rofi.*-name[[:space:]]*${ROFI_NAME}" || true
    exit 0
fi

rofi -show drun -name "${ROFI_NAME}" -theme "${THEME}" -i -p "apps"
