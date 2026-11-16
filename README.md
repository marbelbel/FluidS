# FluidOS - Live Beta

FluidOS es un proyecto de sistema operativo experimental con una interfaz
propia GTK3, GTK Layer Shell y Wayfire.

Esta fase se centra en conseguir una ISO Live reproducible para pruebas:

- Base de FreeBSD 14.5 descargada y verificada mediante SHA256.
- Sistema Live en memoria construido con mfsBSD.
- Escritorio propio FluidOS empaquetado dentro de la imagen.
- Sesion Wayfire anidada sobre Xorg para probar la interfaz en VirtualBox.
- Terminal Foot, gestor Wayfire Config Manager y navegador Firefox.
- Construccion automatica mediante GitHub Actions.

## Construir

La compilacion automatica se inicia desde GitHub Actions:

`https://github.com/marbelbel/FLUID/actions`

El workflow utiliza el entorno FreeBSD 14.5 y publica una ISO comprimida en
GitHub Releases.

## Probar

La ISO se llama `fluidos-14.5-amd64.iso.xz`. Descomprimela antes de conectarla
como CD/DVD en VirtualBox.

Credenciales temporales de la VM:

- Usuario: `fluid`
- Clave: `fluidos`

Configura VirtualBox con VBoxSVGA, 128 MB de memoria de video y aceleracion 3D
desactivada. Empieza con 1 procesador virtual y 8 GB de RAM si el portatil
anfitrion dispone de memoria suficiente. Prueba primero con EFI desactivado.

## Estado

Esta imagen es una Live Beta. Todavia no es un instalador permanente, no
conserva cambios despues de apagar y necesita pruebas de arranque grafico,
compatibilidad de hardware, red, sonido y aplicaciones.

## Licencias

El proyecto integra componentes de terceros. Consulta sus avisos de licencia
y conserva las atribuciones correspondientes antes de redistribuir imagenes.
