#!/bin/bash

THEME="$HOME/.config/rofi/hypr-purple.rasi"

# Toggle del launcher
if pgrep -x rofi >/dev/null 2>&1; then
    pkill -x rofi
    exit 0
fi

roots=(
    "hypr:$HOME/.config/hypr"
    "scripts:$HOME/.local/bin"
    "rofi:$HOME/.config/rofi"
    "waybar:$HOME/.config/waybar"
)

open_in_terminal() {
    local cmd="$1"
    if command -v kitty >/dev/null 2>&1; then
        kitty bash -lc "$cmd; echo; echo 'Presiona Enter para cerrar...'; read -r"
    else
        notify-send "hypr-open-config" "kitty no esta instalado"
        return 1
    fi
}

run_action() {
    case "$1" in
        "sync-dotfiles")
            # Ejecutar vía bash para no depender del bit de ejecución del archivo.
            open_in_terminal "bash \"$HOME/.local/bin/scripts/sync-dotfiles.sh\""
            ;;
        *)
            return 1
            ;;
    esac
}

open_target() {
    local target="$1"
    if command -v cursor >/dev/null 2>&1; then
        cursor "$target"
    elif command -v code >/dev/null 2>&1; then
        code "$target"
    else
        xdg-open "$target"
    fi
}

pick_root() {
    local entries=()
    local root name dir

    entries+=("ACTION sync-dotfiles :: sync-dotfiles")

    for root in "${roots[@]}"; do
        name="${root%%:*}"
        dir="${root#*:}"
        [ -d "$dir" ] || continue
        entries+=("$name :: $dir")
    done

    [ "${#entries[@]}" -eq 0 ] && exit 0
    printf '%s\n' "${entries[@]}" | sort -u | rofi -dmenu -i -p "seccion" -theme "$THEME"
}

browse_dir() {
    local root="$1"
    local current="$1"
    local choice path base entries prompt

    while true; do
        entries=()
        prompt="${current#"$root"/}"
        [ "$current" = "$root" ] && prompt="/"
        [ -z "$prompt" ] && prompt="/"
        entries+=("<< volver a secciones")
        entries+=(". abrir carpeta actual :: $current")
        if [ "$current" != "$root" ]; then
            entries+=(".. subir carpeta")
        fi

        shopt -s nullglob dotglob
        for path in "$current"/*; do
            [ -e "$path" ] || continue
            base="${path##*/}"
            if [ -d "$path" ]; then
                entries+=("DIR  $base/ :: $path")
            elif [ -f "$path" ]; then
                entries+=("FILE $base :: $path")
            fi
        done

        choice="$(printf '%s\n' "${entries[@]}" | sort -u | rofi -dmenu -i -p "$prompt" -theme "$THEME")"
        [ -z "$choice" ] && exit 0

        if [ "$choice" = "<< volver a secciones" ]; then
            return 1
        fi

        if [ "$choice" = ".. subir carpeta" ]; then
            if [ "$current" = "$root" ]; then
                continue
            fi
            current="${current%/*}"
            case "$current" in
                "$root"/*|"$root") ;;
                *) current="$root" ;;
            esac
            continue
        fi

        path="${choice##* :: }"

        if [ "$path" = "$choice" ]; then
            continue
        fi

        if [ "$path" = "$current" ]; then
            open_target "$current"
            exit 0
        fi

        if [ -d "$path" ]; then
            current="$path"
            continue
        fi

        open_target "$path"
        exit 0
    done
}

selected_root="$(pick_root)"
[ -z "$selected_root" ] && exit 0
if [[ "$selected_root" == ACTION* ]]; then
    run_action "${selected_root##* :: }"
    exit 0
fi
start_dir="${selected_root##* :: }"
[ -z "$start_dir" ] && exit 0

while true; do
    browse_dir "$start_dir"
    code="$?"
    [ "$code" -eq 0 ] && exit 0

    selected_root="$(pick_root)"
    [ -z "$selected_root" ] && exit 0
    if [[ "$selected_root" == ACTION* ]]; then
        run_action "${selected_root##* :: }"
        exit 0
    fi
    start_dir="${selected_root##* :: }"
    [ -z "$start_dir" ] && exit 0
done
