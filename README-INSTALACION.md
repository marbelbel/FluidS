# FluidOS Live Beta: construccion y prueba

Esta version genera una ISO Live basada en FreeBSD 14.5 y mfsBSD. mfsBSD carga
un sistema raiz en memoria, por lo que el arranque no depende de un conjunto
ZFS `zroot/ROOT/default` que no exista en la ISO.

## Construccion

GitHub Actions ejecuta tres pasos:

1. `build-os.sh`: descarga `base.txz` y `kernel.txz`, verifica sus SHA256 y
   obtiene una revision fijada del constructor mfsBSD.
2. `setup-features.sh` y `setup-desktop.sh`: preparan paquetes, configuracion,
   usuario `fluid` y la shell GTK del repositorio.
3. `make-iso.sh`: utiliza el objetivo `iso` de mfsBSD y comprueba los archivos
   principales de arranque. El constructor genera arranque BIOS y UEFI.

La compilacion se ejecuta en el entorno FreeBSD 14.5 de GitHub Actions.

## Escritorio de prueba

Para facilitar la prueba en VirtualBox, el perfil del usuario inicia Xorg y
Wayfire con el backend X11 anidado. Esto evita depender directamente del
acceso DRM de la GPU virtual. Se incluye VirtualBox Guest Additions y Firefox.
En VirtualBox comienza con VBoxSVGA, aceleracion 3D desactivada y un solo
procesador virtual. La guia oficial de FreeBSD recomienda VBoxSVGA para Xorg;
la documentacion del paquete tambien advierte que un solo vCPU puede ayudar a
mitigar algunos bloqueos al cargar el modulo invitado.

## Credenciales temporales

- Usuario: `fluid`
- Clave: `fluidos`
- SSH: desactivado

No usar estas claves para una distribucion publica.

## Limitaciones conocidas

- Es una Live ISO de prueba, no un instalador de disco.
- La sesion y los archivos creados en ella se pierden al apagar.
- No todas las opciones visuales de la shell controlan aun servicios reales.
- La compilacion comprueba la estructura de la ISO, el archivo de raiz Live y
  los programas esenciales. Eso no sustituye una prueba de arranque real.
- Los controles de red, Bluetooth, volumen y brillo de la interfaz siguen
  siendo visuales; no se deben considerar funcionales todavia.
