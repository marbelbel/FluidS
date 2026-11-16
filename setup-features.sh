#!/bin/sh
# ==============================================================================
# FluidOS - Preparacion de configuracion, paquetes y archivos del sistema Live
# ==============================================================================

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUILD_ROOT="${FLUIDOS_BUILD_ROOT:-/usr/obj/fluidos-build}"
MFSBSD_DIR="$BUILD_ROOT/mfsbsd"

info() { printf '[INFO] %s\n' "$1"; }
error() { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || error "Ejecuta este script como root."
[ -f "$MFSBSD_DIR/Makefile" ] || error "No se encuentra el constructor. Ejecuta antes build-os.sh."

info "Instalando la configuracion propia de FluidOS en el constructor..."

for FILE in loader.conf rc.conf rc.local ttys hosts; do
    [ -s "$SCRIPT_DIR/mfsbsd/conf/$FILE" ] || error "Falta mfsbsd/conf/$FILE"
    install -m 0644 "$SCRIPT_DIR/mfsbsd/conf/$FILE" "$MFSBSD_DIR/conf/$FILE"
done

install -m 0644 "$SCRIPT_DIR/mfsbsd/tools/packages" "$MFSBSD_DIR/tools/packages"
install -m 0644 "$SCRIPT_DIR/mfsbsd/tools/motd" "$MFSBSD_DIR/tools/motd"

sh "$SCRIPT_DIR/setup-desktop.sh" "$MFSBSD_DIR"

info "Configuracion Live preparada."
info "Paquetes, usuario de prueba, Xorg y escritorio propio listos para empaquetar."
