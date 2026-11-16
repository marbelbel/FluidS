#!/bin/sh
# ==============================================================================
# FluidOS - Descarga validada de los conjuntos base y del constructor Live ISO
# ==============================================================================

set -eu

BUILD_ROOT="${FLUIDOS_BUILD_ROOT:-/usr/obj/fluidos-build}"
DIST_DIR="$BUILD_ROOT/dist"
MFSBSD_DIR="$BUILD_ROOT/mfsbsd"
VERSION="14.5-RELEASE"
ARCH="amd64"
MFSBSD_COMMIT="6e48fa48ebbb25953a7764a8f3cfda443fb9a768"
BASE_URL="https://download.freebsd.org/releases/$ARCH/$ARCH/$VERSION"

info() { printf '[INFO] %s\n' "$1"; }
error() { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || error "Ejecuta este script como root dentro del entorno de compilacion."

if ! command -v git >/dev/null 2>&1; then
    info "Instalando git-lite..."
    pkg install -y git-lite
fi

if [ ! -x /usr/local/sbin/pkg-static ]; then
    info "Preparando pkg-static para el constructor de la ISO..."
    env ASSUME_ALWAYS_YES=yes pkg bootstrap -f
fi

[ -x /usr/local/sbin/pkg-static ] || error "No se pudo preparar /usr/local/sbin/pkg-static."

info "Preparando el directorio de construccion..."
rm -rf "$BUILD_ROOT"
mkdir -p "$DIST_DIR"

info "Descargando los archivos oficiales de la version $VERSION..."
fetch -o "$DIST_DIR/CHECKSUM.SHA256" "$BASE_URL/CHECKSUM.SHA256"

for SET_NAME in base.txz kernel.txz; do
    fetch -o "$DIST_DIR/$SET_NAME" "$BASE_URL/$SET_NAME"
    EXPECTED=$(awk -v wanted="($SET_NAME)" '$2 == wanted {print $4; exit}' "$DIST_DIR/CHECKSUM.SHA256")
    [ -n "$EXPECTED" ] || error "No se encontro el hash oficial de $SET_NAME."
    ACTUAL=$(sha256 -q "$DIST_DIR/$SET_NAME")
    [ "$EXPECTED" = "$ACTUAL" ] || error "El hash SHA256 de $SET_NAME no coincide."
    info "$SET_NAME verificado correctamente."
done

info "Descargando el constructor mfsBSD (revision fijada)..."
git clone --quiet https://github.com/mmatuska/mfsbsd.git "$MFSBSD_DIR"
git -C "$MFSBSD_DIR" checkout --quiet --detach "$MFSBSD_COMMIT"

ACTUAL_COMMIT=$(git -C "$MFSBSD_DIR" rev-parse HEAD)
[ "$ACTUAL_COMMIT" = "$MFSBSD_COMMIT" ] || error "La revision del constructor no coincide."

info "Base preparada: $DIST_DIR"
info "Constructor preparado: $MFSBSD_DIR"
info "Siguiente paso: ./setup-features.sh"
