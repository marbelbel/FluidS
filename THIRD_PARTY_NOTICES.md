# Avisos de terceros

## mfsBSD

FluidOS utiliza mfsBSD como constructor de la imagen Live. Se descarga durante
la compilacion desde https://github.com/mmatuska/mfsbsd y se fija a la revision:

`6e48fa48ebbb25953a7764a8f3cfda443fb9a768`

El proyecto mfsBSD declara licencia BSD-2-Clause y copyright de Martin Matuska.
Su codigo y licencia permanecen en el repositorio original. No se debe eliminar
su aviso de licencia al redistribuir componentes derivados.

## FreeBSD

La imagen incorpora los conjuntos oficiales `base.txz` y `kernel.txz` de
FreeBSD 14.5-RELEASE. Conserva los avisos de copyright y licencia que vienen
con esos conjuntos y los de todos los paquetes instalados.
