#!/usr/bin/env bash
# ==============================================================================
# 01-live-btrfs-setup.sh — FASE 1: ejecutar desde el live USB (Ventoy)
#
# Cuándo: DESPUÉS de que el instalador de Linux Mint termine y ANTES de reiniciar
#         (en el instalador elige "Continuar probando", no "Reiniciar").
#
# Qué hace:
#   1. Localiza la partición Btrfs recién instalada y monta el top-level (subvolid=5)
#   2. Comprueba que existen los subvolúmenes @ (y @home si lo hay)
#   3. Crea @var_log, @var_cache y @var_tmp y migra su contenido
#   4. Ajusta el /etc/fstab instalado: noatime, compress=zstd:1, fsck=0
#   5. Añade al fstab los subvolúmenes nuevos
#
# Uso:  ./01-live-btrfs-setup.sh [--device /dev/XXX] [--yes]
# ==============================================================================

set -Eeuo pipefail

# ── Colores ───────────────────────────────────────────────────────────────────
RC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

# ── Helpers ───────────────────────────────────────────────────────────────────
msg()  { printf "%b\n" "${CYAN}[INFO]${RC}  $*"; }
ok()   { printf "%b\n" "${GREEN}[OK]${RC}    $*"; }
warn() { printf "%b\n" "${YELLOW}[AVISO]${RC} $*" >&2; }
err()  { printf "%b\n" "${RED}[ERROR]${RC} $*" >&2; exit 1; }

usage() { sed -n '2,/^# ====/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0; }

# ── Configuración ─────────────────────────────────────────────────────────────
TOP_MNT="/mnt/btrfs-top"
OPTS="noatime,compress=zstd:1"
# formato "subvolumen:punto_de_montaje"
EXTRA_SUBVOLS=( "@var_log:/var/log" "@var_cache:/var/cache" "@var_tmp:/var/tmp" )
DEVICE=""
ASSUME_YES=0

# ── Escalado de privilegios ───────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo &>/dev/null || err "Necesitas root o sudo."
    exec sudo -E bash "$0" "$@"
fi

confirm() {
    [ "${ASSUME_YES}" -eq 1 ] && return 0
    local ans
    read -r -p "$1 [s/N] " ans
    [[ "${ans}" =~ ^[sSyY]$ ]]
}

cleanup() {
    if mountpoint -q "${TOP_MNT}" 2>/dev/null; then
        umount "${TOP_MNT}" || warn "No se pudo desmontar ${TOP_MNT}"
    fi
}
trap cleanup EXIT
trap 'err "Fallo en la línea ${LINENO} (comando: ${BASH_COMMAND})"' ERR

# ── Argumentos ────────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --device)  DEVICE="${2:-}"; shift 2 ;;
        --yes|-y)  ASSUME_YES=1; shift ;;
        -h|--help) usage ;;
        *) err "Argumento desconocido: $1" ;;
    esac
done

command -v btrfs &>/dev/null || err "Falta btrfs-progs (en el live: sudo apt install btrfs-progs)."

# ── 1. Localizar la partición ─────────────────────────────────────────────────
select_device() {
    mapfile -t cands < <(lsblk -rpno NAME,FSTYPE | awk '$2=="btrfs"{print $1}')
    [ "${#cands[@]}" -gt 0 ] || err "No se ha encontrado ninguna partición Btrfs."
    if [ "${#cands[@]}" -eq 1 ]; then
        DEVICE="${cands[0]}"
        return
    fi
    msg "Hay varias particiones Btrfs:"
    lsblk -o NAME,SIZE,FSTYPE,LABEL,MODEL,MOUNTPOINTS "${cands[@]}"
    PS3="Elige la partición raíz del sistema recién instalado: "
    select d in "${cands[@]}"; do
        if [ -n "${d:-}" ]; then DEVICE="$d"; break; fi
    done
}

[ -n "${DEVICE}" ] || select_device
[ -b "${DEVICE}" ] || err "${DEVICE} no es un dispositivo de bloque."
[ "$(blkid -s TYPE -o value "${DEVICE}")" = "btrfs" ] || err "${DEVICE} no es Btrfs."

# Protección: no tocar un sistema que está en uso
if [[ "$(findmnt -no SOURCE /)" == "${DEVICE}"* ]]; then
    err "${DEVICE} es el / del sistema en ejecución. Esta fase debe lanzarse desde el live USB."
fi

UUID="$(blkid -s UUID -o value "${DEVICE}")"
msg "Partición raíz: ${DEVICE} (UUID=${UUID})"

# ── 2. Montar top-level y validar ─────────────────────────────────────────────
mkdir -p "${TOP_MNT}"
if mountpoint -q "${TOP_MNT}"; then umount "${TOP_MNT}"; fi
mount -o subvolid=5 "${DEVICE}" "${TOP_MNT}"

[ -d "${TOP_MNT}/@" ] || err "No existe el subvolumen @ en ${DEVICE}. ¿Terminó la instalación? ¿Es la partición correcta?"
[ -f "${TOP_MNT}/@/etc/fstab" ] || err "No se encuentra @/etc/fstab: la instalación parece incompleta."
if [ ! -d "${TOP_MNT}/@home" ]; then
    warn "No hay subvolumen @home (¿/home en otra partición?). Timeshift y tu layout deberían revisarse."
fi

msg "Subvolúmenes actuales:"
btrfs subvolume list "${TOP_MNT}" | sed 's/^/    /'

printf "\n"
msg "Plan:"
printf "    - Crear subvolúmenes: %s\n" "$(printf '%s ' "${EXTRA_SUBVOLS[@]%%:*}")"
printf "    - Migrar el contenido actual de /var/log, /var/cache y /var/tmp\n"
printf "    - Opciones de montaje Btrfs en fstab: %s\n" "${OPTS}"
printf "    - Copia de seguridad del fstab: fstab.bak-<fecha>\n"
confirm "¿Continuar?" || err "Cancelado."

# ── 3. Crear subvolúmenes y migrar contenido ──────────────────────────────────
for entry in "${EXTRA_SUBVOLS[@]}"; do
    sv="${entry%%:*}"; mp="${entry#*:}"
    dst="${TOP_MNT}/${sv}"
    src="${TOP_MNT}/@${mp}"

    if [ -d "${dst}" ]; then
        warn "${sv} ya existe, se omite la creación."
        continue
    fi

    btrfs subvolume create "${dst}" >/dev/null
    ok "Creado ${sv}"

    if [ -d "${src}" ]; then
        chmod --reference="${src}" "${dst}"
        chown --reference="${src}" "${dst}"
        cp -a --reflink=auto "${src}/." "${dst}/"
        # vaciar el original: quedaría tapado por el montaje y solo ocuparía espacio
        find "${src}" -mindepth 1 -delete
        ok "Contenido de ${mp} migrado a ${sv}"
    fi
done

# ── 4. Ajustar fstab ──────────────────────────────────────────────────────────
FSTAB="${TOP_MNT}/@/etc/fstab"
cp -a "${FSTAB}" "${FSTAB}.bak-$(date +%Y%m%d-%H%M%S)"

tmp="$(mktemp)"
awk '
  /^[[:space:]]*#/ || NF < 4 { print; next }
  $3 == "btrfs" {
    if ($4 !~ /(^|,)noatime(,|$)/)        $4 = $4 ",noatime"
    if ($4 !~ /(^|,)compress(-force)?=/)  $4 = $4 ",compress=zstd:1"
    if ($5 == "") $5 = 0
    $6 = 0                                  # Btrfs no usa fsck al arrancar
    print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6
    next
  }
  { print }
' "${FSTAB}" > "${tmp}"
cat "${tmp}" > "${FSTAB}"
rm -f "${tmp}"
ok "Opciones de montaje actualizadas en fstab"

# ── 5. Añadir subvolúmenes nuevos al fstab ────────────────────────────────────
for entry in "${EXTRA_SUBVOLS[@]}"; do
    sv="${entry%%:*}"; mp="${entry#*:}"
    if grep -Eq "subvol=/?${sv}([,[:space:]]|$)" "${FSTAB}"; then
        warn "${sv} ya figura en fstab, se omite."
    else
        printf 'UUID=%s\t%s\tbtrfs\tdefaults,%s,subvol=%s\t0\t0\n' \
            "${UUID}" "${mp}" "${OPTS}" "${sv}" >> "${FSTAB}"
        ok "fstab: ${mp} -> ${sv}"
    fi
done

printf "\n"
msg "fstab final:"
grep -Ev '^[[:space:]]*(#|$)' "${FSTAB}" | sed 's/^/    /'

printf "\n"
ok "Fase 1 completada. Ya puedes reiniciar y quitar el USB."
msg "Después, en el sistema instalado:  ./02-post-install-base.sh"
