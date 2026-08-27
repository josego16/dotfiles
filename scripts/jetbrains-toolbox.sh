#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains/Toolbox"
SYMLINK_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
TMP_DIR="$(mktemp -d)"

# ─── COLORES ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── UTILIDADES ───────────────────────────────────────────────────────────────

trap 'rm -rf "$TMP_DIR"' EXIT

log()  { printf "\n${CYAN}${BOLD}[%s]${NC} %s\n" "$(date +'%H:%M:%S')" "$*"; }
warn() { printf "${YELLOW}[WARN]${NC}  %s\n" "$*" >&2; }
die()  { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }

is_installed() { command -v "$1" >/dev/null 2>&1; }

# ─── DEPENDENCIAS ─────────────────────────────────────────────────────────────

check_deps() {
  is_installed curl || is_installed wget \
    || die "Se requiere curl o wget. Instala uno de ellos antes de continuar."
  is_installed tar \
    || die "Se requiere tar. Instala tar antes de continuar."
  is_installed jq || is_installed python3 \
    || die "Se requiere jq o python3 para procesar la API de JetBrains."
}

# ─── HTTP ─────────────────────────────────────────────────────────────────────

# Obtiene el contenido de una URL y lo escribe en stdout.
http_fetch() {
  if is_installed curl; then
    curl -fsSL "$1"
  else
    wget -qO- "$1"
  fi
}

# Descarga una URL a un archivo destino con barra de progreso.
http_download() {
  local url="$1" dest="$2"
  if is_installed wget; then
    wget -q --show-progress -cO "$dest" "$url"
  else
    curl -L --progress-bar -o "$dest" "$url"
  fi
}

# ─── PATH ─────────────────────────────────────────────────────────────────────

ensure_path_line() {
  local line="$1" file="$2"
  touch "$file"
  grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

persist_local_bin_path() {
  local export_line="export PATH=\"$SYMLINK_DIR:\$PATH\""
  ensure_path_line "$export_line" "$HOME/.bashrc"
  ensure_path_line "$export_line" "$HOME/.profile"   # login shells (Debian, Arch, etc.)
  is_installed zsh && ensure_path_line "$export_line" "$HOME/.zshrc"
  export PATH="$SYMLINK_DIR:$PATH"
}

# ─── DESCARGA ─────────────────────────────────────────────────────────────────

resolve_archive_url() {
  local json
  json="$(http_fetch 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release')"

  if is_installed jq; then
    jq -r '.TBA[0].downloads.linux.link' <<< "$json"
    return
  fi

  # Nota: se usa -c para separar el script del JSON que llega por stdin.
  # La combinación de pipe + heredoc no funciona correctamente porque el
  # heredoc sobreescribe stdin, dejando sys.stdin vacío en Python.
  python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data['TBA'][0]['downloads']['linux']['link'])
" <<< "$json"
}

# ─── PRINCIPAL ────────────────────────────────────────────────────────────────

main() {
  check_deps

  # No usar `command -v`: podría encontrar una instalación del sistema y
  # ocultar que falta la instalación del usuario actual.
  [[ -x "$INSTALL_DIR/bin/jetbrains-toolbox" ]] && {
    mkdir -p "$SYMLINK_DIR"
    ln -sfn "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"
    persist_local_bin_path
    log "JetBrains Toolbox ya está instalado para este usuario."
    return
  }

  log "Instalando JetBrains Toolbox..."
  mkdir -p "$INSTALL_DIR" "$SYMLINK_DIR"

  log "Obteniendo URL de descarga..."
  local archive_url
  archive_url="$(resolve_archive_url)"

  [[ -n "${archive_url:-}" && "$archive_url" != "null" ]] \
    || die "No se pudo resolver la URL de descarga de JetBrains Toolbox."

  local archive_filename
  archive_filename="$(basename "$archive_url")"

  log "Descargando $archive_filename..."
  http_download "$archive_url" "$TMP_DIR/$archive_filename"

  log "Extrayendo en $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"/*
  tar -xzf "$TMP_DIR/$archive_filename" -C "$INSTALL_DIR" --strip-components=1
  chmod +x "$INSTALL_DIR/bin/jetbrains-toolbox"

  log "Creando enlace simbólico..."
  ln -sfn "$INSTALL_DIR/bin/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

  persist_local_bin_path

  if [[ -z "${CI:-}" ]] && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    log "Iniciando JetBrains Toolbox para la primera configuración..."
    nohup "$INSTALL_DIR/bin/jetbrains-toolbox" >/dev/null 2>&1 &
    disown || true
  else
    warn "Sin sesión gráfica o CI detectado — omitiendo lanzamiento de GUI."
  fi

  printf "\n${GREEN}${BOLD}✓ JetBrains Toolbox instalado correctamente.${NC}\n\n"
}

main
