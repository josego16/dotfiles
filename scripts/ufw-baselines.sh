#!/bin/bash
# ==============================================================================
# ufw-baselines.sh — Configuración base de UFW (standalone)
# Detecta automáticamente el gestor de paquetes y la herramienta de escalado.
# Compatible con: Fedora, Linux Mint/Ubuntu/Debian, Arch, Void, Alpine.
# ==============================================================================

set -euo pipefail

# ── Colores ───────────────────────────────────────────────────────────────────
RC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

# ── Helpers ───────────────────────────────────────────────────────────────────
msg()  { printf "%b\n" "${CYAN}[INFO]${RC}  $*"; }
ok()   { printf "%b\n" "${GREEN}[OK]${RC}    $*"; }
warn() { printf "%b\n" "${YELLOW}[AVISO]${RC} $*"; }
err()  { printf "%b\n" "${RED}[ERROR]${RC} $*" >&2; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

# ── Comprobaciones previas ────────────────────────────────────────────────────
check_env() {
    if [ "$(id -u)" -eq 0 ]; then
        ESCALATION_TOOL=""          # ya somos root, no se necesita sudo/doas
        msg "Ejecutando como root."
    elif command_exists sudo; then
        ESCALATION_TOOL="sudo"
        msg "Herramienta de escalado: sudo"
    elif command_exists doas; then
        ESCALATION_TOOL="doas"
        msg "Herramienta de escalado: doas"
    else
        err "No se encontró sudo ni doas. Ejecuta el script como root."
    fi
}

detect_packager() {
    if command_exists dnf;           then PACKAGER="dnf"
    elif command_exists apt-get;     then PACKAGER="apt-get"
    elif command_exists pacman;      then PACKAGER="pacman"
    elif command_exists xbps-install;then PACKAGER="xbps-install"
    elif command_exists apk;         then PACKAGER="apk"
    elif command_exists zypper;      then PACKAGER="zypper"
    else err "No se reconoció ningún gestor de paquetes compatible."; fi
    msg "Gestor de paquetes detectado: ${PACKAGER}"
}

run() {
    # Ejecuta un comando con o sin herramienta de escalado según corresponda
    if [ -z "${ESCALATION_TOOL}" ]; then
        "$@"
    else
        "${ESCALATION_TOOL}" "$@"
    fi
}

# ── Instalación ───────────────────────────────────────────────────────────────
install_ufw() {
    if command_exists ufw; then
        ok "UFW ya está instalado."
        return
    fi

    warn "UFW no encontrado. Instalando..."
    case "${PACKAGER}" in
        dnf)          run dnf install -y ufw ;;
        apt-get)      run apt-get install -y ufw ;;
        pacman)       run pacman -S --needed --noconfirm ufw ;;
        xbps-install) run xbps-install -Sy ufw ;;
        apk)          run apk add ufw ;;
        zypper)       run zypper install -y ufw ;;
    esac
    ok "UFW instalado correctamente."
}

# ── Configuración ─────────────────────────────────────────────────────────────
configure_ufw() {
    printf "\n"
    msg "Aplicando reglas base de cortafuegos..."

    warn "Deshabilitando UFW antes de reconfigurar..."
    run ufw disable || true         # 'true' evita error si ya estaba desactivado

    warn "Limpiando reglas anteriores (reset)..."
    run ufw --force reset           # --force suprime la confirmación interactiva

    warn "Denegando tráfico entrante por defecto..."
    run ufw default deny incoming

    msg "Permitiendo tráfico saliente por defecto..."
    run ufw default allow outgoing

    msg "Denegando tráfico reenviado por defecto..."
    run ufw default deny routed

    msg "Permitiendo loopback local..."
    run ufw allow in on lo

    msg "Limitando SSH — puerto 22/tcp (protección anti-fuerza bruta)..."
    run ufw limit 22/tcp

    msg "Activando logging básico..."
    run ufw logging low

    warn "Habilitando UFW..."
    run ufw --force enable

    printf "\n"
    ok "¡Cortafuegos activado con las reglas base!"
    printf "\n"
    run ufw status verbose
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    printf "\n%b\n\n" "${CYAN}══ UFW Baselines — Configuración de cortafuegos ══${RC}"
    check_env
    detect_packager
    install_ufw
    configure_ufw
}

main
