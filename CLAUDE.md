# OldieChat: reglas para trabajar en este repositorio

Lee primero `docs/ESTADO.md` (qué está hecho y para qué sirve cada carpeta).

## Código minimal

La app es minimal, y el código también tiene que serlo:

- Agrega lo mínimo que resuelve el problema; elimina lo que deja de usarse
  (funciones, opciones, atajos, scripts, archivos).
- En nchat, desactiva lo que no se usa con opciones de compilación o de
  configuración antes que con código.
- Parches a nchat pequeños, uno por tema, en `nchat/patches/` y numerados sin
  huecos, para que actualizar nchat siga siendo fácil. Las opciones nuevas van
  apagadas por defecto en nchat y se encienden en `phone/config/`.
- Antes de borrar algo grande o cambiar la estructura, muestra un inventario y
  espera la aprobación del dueño.

## Pruebas en el teléfono

- **No inyectes teclas por ADB** (`adb shell input`, ni manejar nchat por una
  pseudo-terminal) en las conversaciones reales del dueño sin avisarle antes.
  Para probar la interfaz, escribe qué hacer y que lo haga él, o usa solo
  pantallas donde no se pueda enviar nada.
- Las pruebas automáticas que no tocan conversaciones están bien:
  `scripts/phone-test.sh`, `scripts/glyphs.sh`, capturas de un shell.

## Publicación

- Solo commits locales. El dueño sube a GitHub y publica los Releases.
- Antes de cerrar una versión: `VERSION`, `CHANGELOG.md`, README (español e
  inglés), `docs/ESTADO.md` y `scripts/phone-test.sh --sound` en el teléfono.
- Responde en español, en pasos cortos.
