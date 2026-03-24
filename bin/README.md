# Mis scripts

Este README documenta mis scripts personalizados para Hyprland.

## Ubicacion

Los scripts viven en:

- `~/.local/bin/glass-toggle.sh`
- `~/.local/bin/wofi-toggle.sh`
- `~/.local/bin/hyprpaper-guard.sh`

## Scripts

### `glass-toggle.sh`

Hace toggle de "modo glass" en la ventana activa.

- Si la ventana esta en modo normal:
  - fuerza opacidad activa/inactiva a `1.0`
  - desactiva blur en esa ventana
- Si la ventana ya esta en modo glass-toggle:
  - quita los overrides
  - la ventana vuelve a usar la config global de Hyprland

Tecnico:

- toma la ventana activa con `hyprctl activewindow -j | jq`
- guarda estado por ventana en `/tmp/hypr-solid-<address>`

Atajo:

- `SUPER + T`

---

### `wofi-toggle.sh`

Abre o cierra `wofi` con una sola tecla.

- Si `wofi` ya esta abierto: lo mata (`pkill -x wofi`)
- Si no esta abierto: lo lanza (`wofi --show drun`)

Atajo:

- `SUPER + Space`

---

### `hyprpaper-guard.sh`

Vigila `hyprpaper` en loop y lo reinicia si se cae.

- cada 5 segundos revisa `pgrep -x hyprpaper`
- si no existe el proceso, ejecuta `hyprpaper`

Uso:

- se ejecuta en autostart con `exec-once`
- sirve para evitar quedarse sin wallpaper si `hyprpaper` crashea

## Dependencias

Para que todo funcione:

- `hyprctl`
- `jq`
- `wofi`
- `hyprpaper`
- `pgrep`/`pkill` (de `procps-ng`)
