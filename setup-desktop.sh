#!/bin/sh
# ==============================================================================
# FluidOS - Preparacion de la shell GTK y la sesion Wayfire anidada en Xorg
# ==============================================================================

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
MFSBSD_DIR="${1:-${FLUIDOS_BUILD_ROOT:-/usr/obj/fluidos-build}/mfsbsd}"
CUSTOMFILES="$MFSBSD_DIR/customfiles"
CUSTOMSCRIPTS="$MFSBSD_DIR/customscripts"

error() { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || error "Ejecuta este script como root."
[ -f "$SCRIPT_DIR/desktop/fluidos-shell.py" ] || error "Falta desktop/fluidos-shell.py."
[ -d "$MFSBSD_DIR" ] || error "No existe el constructor mfsBSD."

mkdir -p "$CUSTOMFILES" "$CUSTOMSCRIPTS"

# Copia los archivos de configuracion que forman parte del repositorio FluidOS.
cp -R "$SCRIPT_DIR/mfsbsd/customfiles/." "$CUSTOMFILES/"

# Instala la shell GTK real del proyecto.
install -d -m 0755 "$CUSTOMFILES/usr/local/lib/fluidos"
install -m 0755 "$SCRIPT_DIR/desktop/fluidos-shell.py" \
    "$CUSTOMFILES/usr/local/lib/fluidos/fluidos-shell.py"

# La etiqueta del navegador y su comando deben corresponder a la aplicacion incluida.
sed -i '' \
    -e 's/FluidWeb/Navegador/g' \
    -e 's,xdg-open https://www.freebsd.org,firefox,g' \
    "$CUSTOMFILES/usr/local/lib/fluidos/fluidos-shell.py"

# Instala el creador del usuario de prueba, que mfsBSD ejecuta durante la construccion.
install -m 0755 "$SCRIPT_DIR/mfsbsd/customscripts/10-create-fluid-user.sh" \
    "$CUSTOMSCRIPTS/10-create-fluid-user.sh"

# Garantiza permisos de ejecucion en los lanzadores.
chmod 0755 "$CUSTOMFILES/usr/local/bin/fluidos-shell" \
           "$CUSTOMFILES/usr/local/bin/fluidos-session"

[ -s "$CUSTOMFILES/home/fluid/.profile" ] || error "No se ha copiado .profile."
[ -s "$CUSTOMFILES/home/fluid/.config/wayfire/wayfire.ini" ] || error "No se ha copiado wayfire.ini."

printf '[OK] Shell y sesion de FluidOS preparadas.\n'
printf '[INFO] La sesion de prueba utilizara Xorg + backend X11 de Wayfire.\n'
