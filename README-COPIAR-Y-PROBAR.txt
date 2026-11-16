FLUIDOS - PAQUETE DE ARRANQUE LIVE PARA PRUEBAS
================================================

QUE CONTIENE
------------
Este paquete sustituye los scripts antiguos de construccion y anade la
configuracion Live basada en mfsBSD. El constructor mfsBSD se descarga desde
una revision fijada de su repositorio; no hace falta copiarlo manualmente.

COMO COPIARLO A GITHUB
----------------------
1. Descarga y extrae este ZIP en Windows.
2. Abre https://github.com/marbelbel/FLUID
3. Pulsa Add file > Upload files.
4. Arrastra los archivos y carpetas extraidos manteniendo sus rutas.
5. Asegurate de sustituir los archivos que ya existan y anadir las carpetas
   nuevas mfsbsd/.
6. Pulsa Commit changes.
7. Abre Actions y ejecuta Construir FluidOS Live ISO si no ha empezado solo.

ARCHIVOS QUE SE SUSTITUYEN
--------------------------
.github/workflows/build-fluidos.yml
build-os.sh
setup-features.sh
setup-desktop.sh
make-iso.sh

ARCHIVOS NUEVOS
---------------
mfsbsd/conf/loader.conf
mfsbsd/conf/rc.conf
mfsbsd/conf/rc.local
mfsbsd/conf/ttys
mfsbsd/conf/hosts
mfsbsd/tools/packages
mfsbsd/tools/motd
mfsbsd/customscripts/10-create-fluid-user.sh
mfsbsd/customfiles/home/fluid/.profile
mfsbsd/customfiles/home/fluid/.config/wayfire/wayfire.ini
mfsbsd/customfiles/usr/local/bin/fluidos-shell
mfsbsd/customfiles/usr/local/bin/fluidos-session
mfsbsd/customfiles/etc/devfs.rules

ARCHIVO EXISTENTE QUE DEBE CONSERVARSE
--------------------------------------
desktop/fluidos-shell.py

El ZIP de cambios utiliza la shell que ya existe en el repositorio y la copia
al sistema Live durante la compilacion. No borres la carpeta desktop/.

COMO PROBAR EN VIRTUALBOX
-------------------------
- Sistema: BSD / FreeBSD (64-bit)
- RAM recomendada: 8 GB; la raiz Live se carga en memoria
- CPU: empieza con 1 procesador virtual por compatibilidad con Guest Additions
- EFI: la ISO incorpora arranque BIOS y UEFI; prueba primero con EFI desactivado
- Pantalla: VBoxSVGA, 128 MB de memoria de video
- Aceleracion 3D: desactivada
- Monta fluidos-14.5-amd64.iso.xz tras descomprimir el archivo XZ
- Inicia desde el lector optico virtual

LOGIN DE PRUEBA
---------------
Usuario: fluid
Clave: fluidos

La cuenta root de la imagen tambien tiene una clave temporal de prueba:
fluidos. SSH se deja desactivado. Estas claves son SOLO para una VM de pruebas;
no publiques ni distribuyas esta imagen sin cambiar las claves.

DIAGNOSTICO
-----------
Si el escritorio falla, el inicio automatico deja la consola disponible y
crea /var/run/fluidos-no-gui para evitar que se repita el intento. Desde esa
consola puedes revisar:

    cat /var/log/Xorg.0.log

Para probar el escritorio manualmente:

    rm -f /var/run/fluidos-no-gui
    startx /usr/local/bin/fluidos-session -- -keeptty

IMPORTANTE
----------
La ISO usa un sistema raiz Live cargado en memoria. Incluye navegador Firefox,
terminal Foot, gestor de ajustes Wayfire y el escritorio FluidOS. No es aun un
instalador para el disco duro y no conserva cambios tras apagar. Los controles
de red, Bluetooth, sonido y brillo de la shell siguen siendo visuales en esta
version y necesitan integracion real.

El paquete prepara y comprueba la estructura de la ISO durante la compilacion.
Eso NO equivale a probar el arranque grafico real: hay que verificarlo en
VirtualBox y corregir cualquier error que aparezca.
