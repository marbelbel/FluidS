#!/bin/sh
# ======================================================================
# FluidOS Live ISO: BIOS + UEFI, basada en mfsBSD
# ======================================================================

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUILD_ROOT="${FLUIDOS_BUILD_ROOT:-/usr/obj/fluidos-build}"
DIST_DIR="$BUILD_ROOT/dist"
MFSBSD_DIR="$BUILD_ROOT/mfsbsd"
WRK_DIR="$BUILD_ROOT/mfsbsd-work"
ISO_NAME="fluidos-14.5-amd64.iso"
ISO_PATH="$SCRIPT_DIR/$ISO_NAME"
CHECK_MOUNT="$BUILD_ROOT/iso-check"
ROOT_FILE_LIST="$BUILD_ROOT/live-root-files.txt"

info() { printf '[INFO] %s\n' "$1"; }
error() { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || error "Ejecuta este script como root."
[ -s "$DIST_DIR/base.txz" ] || error "Falta base.txz. Ejecuta build-os.sh."
[ -s "$DIST_DIR/kernel.txz" ] || error "Falta kernel.txz. Ejecuta build-os.sh."
[ -f "$MFSBSD_DIR/Makefile" ] || error "Falta el constructor mfsBSD."
[ -s "$MFSBSD_DIR/tools/packages" ] || error "Falta la lista de paquetes. Ejecuta setup-features.sh."
[ -s "$MFSBSD_DIR/customfiles/usr/local/lib/fluidos/fluidos-shell.py" ] || error "Falta la shell GTK de FluidOS."
[ -s "$MFSBSD_DIR/customfiles/home/fluid/.profile" ] || error "Falta el perfil del usuario fluid."

command -v makefs >/dev/null 2>&1 || error "makefs no esta disponible."
[ -x /usr/local/sbin/pkg-static ] || error "Falta pkg-static. Ejecuta build-os.sh."

# Cambia la etiqueta original del constructor sin modificar su codigo de arranque.
sed -i '' 's/label=mfsBSD/label=FLUIDOS_14/g' "$MFSBSD_DIR/Makefile"

info "Limpiando solo los resultados anteriores de esta compilacion..."
make -C "$MFSBSD_DIR" clean WRKDIR="$WRK_DIR" >/dev/null 2>&1 || true
rm -f "$ISO_PATH" "$ROOT_FILE_LIST"

info "Construyendo la ISO Live con raiz UFS en memoria."
info "Se incluyen los cargadores BIOS y UEFI proporcionados por mfsBSD."

make -C "$MFSBSD_DIR" iso \
    BASE="$DIST_DIR" \
    WRKDIR="$WRK_DIR" \
    CFGDIR="$MFSBSD_DIR/conf" \
    TOOLSDIR="$MFSBSD_DIR/tools" \
    CUSTOMFILESDIR="$MFSBSD_DIR/customfiles" \
    CUSTOMSCRIPTSDIR="$MFSBSD_DIR/customscripts" \
    RELEASE="14.5-RELEASE" \
    VERSION="14.5-RELEASE" \
    TARGET="amd64" \
    TARGET_ARCH="amd64" \
    IMAGE_PREFIX="fluidos" \
    ISOIMAGE="$ISO_PATH" \
    MFSROOT_MAXSIZE="5g" \
    MFSROOT_FREE_BLOCKS="1%" \
    MFSROOT_FREE_INODES="1%" \
    ROOTPW="fluidos" \
    PERMIT_ROOT_LOGIN="no"

[ -s "$ISO_PATH" ] || error "No se ha generado la ISO."
[ -s "$WRK_DIR/cdboot/cdboot" ] || error "No se ha generado el cargador BIOS."
[ -s "$WRK_DIR/cdboot/efiboot.img" ] || error "No se ha generado la imagen de arranque UEFI."
[ -s "$WRK_DIR/mfs/root.txz" ] || error "No se ha creado el sistema de archivos comprimido."

# Comprueba que el contenido del sistema live empaquetado incluye usuario,
# shell, Wayfire, Xorg y herramientas esenciales antes de generar la entrega.
info "Comprobando los archivos del sistema Live..."
tar -tJf "$WRK_DIR/mfs/root.txz" > "$ROOT_FILE_LIST" || error "No se puede leer root.txz."

for REQUIRED in \
    'rw/etc/master.passwd' \
    'rw/home/fluid/.profile' \
    'rw/home/fluid/.config/wayfire/wayfire.ini' \
    'rw/usr/local/lib/fluidos/fluidos-shell.py' \
    'rw/usr/local/bin/fluidos-shell' \
    'rw/usr/local/bin/fluidos-session' \
    'rw/usr/local/bin/wayfire' \
    'rw/usr/local/bin/Xorg' \
    'rw/usr/local/bin/startx' \
    'rw/usr/local/bin/wcm' \
    'rw/usr/local/bin/firefox'
do
    grep -Fq "$REQUIRED" "$ROOT_FILE_LIST" || error "Falta en el sistema Live: $REQUIRED"
done

# Comprueba la estructura ISO y la imagen comprimida de raiz.
info "Montando la ISO para comprobar los cargadores y el sistema Live..."
mkdir -p "$CHECK_MOUNT"
MD_DEVICE=""
MOUNTED=0

cleanup() {
    if [ "$MOUNTED" -eq 1 ]; then
        umount "$CHECK_MOUNT" >/dev/null 2>&1 || true
        MOUNTED=0
    fi
    if [ -n "$MD_DEVICE" ]; then
        mdconfig -d -u "${MD_DEVICE#md}" >/dev/null 2>&1 || true
        MD_DEVICE=""
    fi
}
trap cleanup EXIT HUP INT TERM

MD_DEVICE="$(mdconfig -a -t vnode -f "$ISO_PATH")"
mount -t cd9660 "/dev/$MD_DEVICE" "$CHECK_MOUNT"
MOUNTED=1

for REQUIRED in \
    boot/loader \
    boot/loader.conf \
    boot/kernel/kernel.gz \
    mfsroot.gz
do
    [ -s "$CHECK_MOUNT/$REQUIRED" ] || error "Falta en la ISO: $REQUIRED"
done

gzip -t "$CHECK_MOUNT/mfsroot.gz" || error "mfsroot.gz esta dañado."

cleanup
trap - EXIT HUP INT TERM

info "Comprobacion estructural completada."
info "ISO generada: $ISO_PATH"
du -h "$ISO_PATH"
printf '\n'
printf '[AVISO] Se han comprobado los archivos de arranque y el sistema Live.\n'
printf '[AVISO] El arranque real y el escritorio aun deben probarse en VirtualBox.\n'
