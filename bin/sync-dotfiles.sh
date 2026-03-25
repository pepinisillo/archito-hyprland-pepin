#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

# Verifica que existe el repo
if [[ ! -d "$DOTFILES/.git" ]]; then
  echo "No existe repo en $DOTFILES"
  exit 1
fi

sync_dir() {
  local src_dir="$1"
  local dest_dir="$2"

  if command -v rsync >/dev/null 2>&1; then
    # Usa rsync para sincronizar y borrar archivos que sobran.
    rsync -a --delete "${src_dir}/" "${dest_dir}/"
    return 0
  fi

  # Fallback cuando no existe rsync: reemplaza el contenido del destino.
  echo "Aviso: 'rsync' no esta instalado. Usando fallback con 'cp' para sincronizar."
  shopt -s dotglob nullglob
  rm -rf "${dest_dir:?}/"*
  shopt -u dotglob nullglob
  cp -a "${src_dir}/." "${dest_dir}/"
}

# Copiar configs
sync_dir "$HOME/.config/hypr" "$DOTFILES/hypr"
sync_dir "$HOME/.local/bin/scripts" "$DOTFILES/bin"

# Commit + push solo si hay cambios
cd "$DOTFILES"
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "sync dotfiles $(date '+%Y-%m-%d %H:%M:%S')"
  git push
  echo "Dotfiles sincronizados y subidos."
else
  echo "Sin cambios."
fi