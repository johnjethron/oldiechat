# Mantener OldieChat vivo

La filosofía del proyecto es que los teléfonos antiguos sigan funcionando. Eso
depende de piezas que cambian o desaparecen: Go, whatsmeow, nchat, Alpine,
libopus y el servidor de mensajería. Este documento dice qué está fijado, cómo
publicar una versión y qué hacer cuando algo se rompe.

## Qué está fijado y dónde

| Pieza | Dónde | Respaldo en el repositorio |
| --- | --- | --- |
| Alpine (imagen de compilación) | `versions.env` (`ALPINE_IMAGE`, por digest) | — |
| Go | `versions.env` (`GO_VERSION`, `GO_SHA256`) | `go/patches/` (parche de musl incluido) |
| nchat | `versions.env` (`NCHAT_COMMIT`) | `nchat/patches/` y el paquete de código fuente de cada versión |
| whatsmeow | `versions.env` (`WHATSMEOW_COMMIT`), para la terminal y el motor | `engine/vendor/`, `nchat/vendor/` |
| Dependencias Go de nchat | `nchat/vendor/` (`go mod vendor`) | sí |
| Fuente de emoji | `versions.env` (`NOTO_EMOJI_COMMIT`, `NOTO_EMOJI_SHA256`) | `phone/fonts/` (`scripts/make-emoji-font.sh`) |
| libopus | `versions.env` (`OPUS_VERSION`, `OPUS_SHA256`) | — |
| d8 y JDK | `versions.env` (`R8_VERSION`, `JDK_IMAGE`) | — |

Cada versión publicada incluye además
`oldiechat-terminal-<versión>-source.tar.gz`: nchat en el commit fijado, con los
parches y las dependencias Go ya incluidas. Con ese archivo, la imagen Alpine y
los tarballs de Go y libopus se puede compilar aunque desaparezcan los
repositorios originales.

Para guardar también la imagen de compilación completa (unos 1,5 GB):

```bash
docker save oldiechat-builder | gzip > oldiechat-builder-<versión>.tar.gz
```

## Publicar una versión

1. `scripts/check-go-version.sh`: que nada exija un Go más nuevo que el fijado.
2. Sube la versión en `VERSION` y anota los cambios en `CHANGELOG.md`.
3. `./build.sh`.
4. Con el teléfono conectado: `out/oldiechat-terminal-<versión>-armv7/install.sh`.
5. `scripts/phone-test.sh --sound`: tiene que terminar en "Todo pasó".
6. Prueba a mano en TermOne Plus: abrir con `wsp`, enviar un mensaje, escuchar
   una nota de voz, ver los archivados. No se prueba inyectando teclas por ADB en
   conversaciones reales.
7. Commit, etiqueta `v<versión>` y Release en GitHub con el `.tar.gz`, su
   `.sha256` y el paquete de código fuente.

## Si Go deja de funcionar en kernels antiguos

Go 1.24 o más nuevo pide oficialmente Linux 3.2; el Galaxy Fame tiene 3.0.101 y
hoy funciona. Si una versión nueva de Go falla en el teléfono:

**Síntomas**: el binario termina apenas arranca, con `bad system call`
(`SIGSYS`), `fatal error: ...` del runtime, o un error `function not implemented`
(`ENOSYS`) en algo que antes funcionaba.

**Encontrar la llamada al sistema**:

1. Compila `strace` estático en el contenedor (`apk add strace` trae la versión
   dinámica; compílalo desde el código con `LDFLAGS=-static`) y cópialo al
   teléfono.
2. Ejecuta el binario que falla:
   `strace -f -o /data/local/tmp/trace.txt <binario> --version`.
3. Busca `ENOSYS` o la última llamada antes del fallo:
   `grep -n ENOSYS trace.txt`.
4. Busca esa llamada en `GOROOT/src/runtime` y `GOROOT/src/syscall`, y revisa
   las notas de la versión de Go.

**Parchear**:

- Si existe una llamada antigua equivalente (por ejemplo `epoll_wait` en vez de
  `epoll_pwait2`, o leer `/dev/urandom` en vez de `getrandom`), agrega en el
  runtime un respaldo que la use cuando la nueva devuelva `ENOSYS`. Muchas
  partes de Go ya hacen eso.
- Guarda el cambio como `go/patches/<número>-<descripción>.patch`.
  `Dockerfile.armv7` aplica todo lo que haya en esa carpeta en orden (ver
  `go/patches/README.md`).
- Si no tiene arreglo razonable, quédate en la última versión de Go que
  funciona: es lo que fija `GO_VERSION`.

## Si whatsmeow exige un Go más nuevo

`scripts/check-go-version.sh` lo avisa con `NUEVO`.

1. Sube `GO_VERSION` y `GO_SHA256` en `versions.env` (checksum del archivo
   `linux-armv6l` en `https://go.dev/dl/?mode=json`).
2. Reaplica el parche de musl (abajo).
3. Compila y prueba en el teléfono (`scripts/phone-test.sh`) antes de publicar.
4. Si el Go nuevo falla en el kernel antiguo, aplica la sección anterior.

## Reaplicar el parche de musl

`go/patches/0001-musl-argv-pr69325.patch` (Go PR #69325, aún sin aceptar en
Go) evita que la parte Go de nchat se caiga al arrancar sobre musl. Lo
mantenemos nosotros; sin él la terminal no arranca. Al cambiar de versión de Go:

1. Descarga el código: `curl -fsSL https://go.dev/dl/go<versión>.src.tar.gz | tar xz`.
2. Prueba: `patch -p1 --dry-run -d go < go/patches/0001-musl-argv-pr69325.patch`.
   Si solo avisa `offset`, no hay que cambiar nada (así entra en Go 1.27.3).
3. Si un bloque falla: aplícalo sin `--dry-run`, corrige a mano los `.rej` en
   `go/src/runtime`, y regenera el parche con
   `diff -ruN go.orig/src go/src` (conserva el encabezado).
4. Anota en el encabezado del parche sobre qué versión de Go quedó.
5. Si Go acepta el PR #69325, borra el parche.

**No conviene quedarse en un whatsmeow viejo por mucho tiempo**: el servidor
rechaza clientes con versiones de protocolo antiguas (nchat lo explica en
`doc/WMOUTDATED.md`). Se puede estar algunas semanas detrás; no meses.

## Actualizar whatsmeow

No hace falta esperar a nchat. Con internet:

```bash
scripts/update-whatsmeow.sh            # último commit de whatsmeow
scripts/update-whatsmeow.sh <commit>   # o uno en particular
```

Fija `WHATSMEOW_COMMIT` en `versions.env` y ejecuta `scripts/vendor-go.sh`,
que usa `utils/whatsmeow-update` de nchat (copia whatsmeow, aplica el parche de
nchat, cambia la fecha en `gowm.go` y hace `go mod tidy`) y guarda las
dependencias de la terminal y del motor. Después: `./build.sh` y
`scripts/phone-test.sh`.

Si se detiene en `.rej`, el parche de nchat
(`lib/wmchat/go/ext/nchat-whatsmeow.patch`) ya no entra en ese whatsmeow; si
falla la compilación de `gowm.go` o de `engine/wa`, whatsmeow cambió su API.
En los dos casos: espera a que nchat se adapte o corrígelo con un parche en
`nchat/patches/`.

## Actualizar nchat

1. Cambia `NCHAT_COMMIT` en `versions.env`.
2. `./build.sh`: si un parche ya no se aplica, `git apply` lo indica. Corrígelo en
   `work/nchat` y regenéralo con `git diff`.
3. Regenera las dependencias Go vendorizadas: `scripts/vendor-go.sh`.

## Si cambian las fuentes del teléfono

`phone/config/glyphs.txt` (qué caracteres se muestran y qué ancho tienen) se mide
en el teléfono. Si cambian sus fuentes (otro modelo, o la fuente de emoji recién
instalada y el teléfono reiniciado), vuelve a medir:

```bash
scripts/glyphs.sh
```

Para cambiar la versión de la fuente de emoji: actualiza `NOTO_EMOJI_COMMIT` y
`NOTO_EMOJI_SHA256` en `versions.env` y ejecuta `scripts/make-emoji-font.sh`.

## Actualizar los certificados

- **En el teléfono**: `install.sh` copia los certificados raíz del equipo
  (`/etc/ssl/certs/ca-certificates.crt`) a
  `/system/etc/ssl/certs/ca-certificates.crt`. Para actualizarlos basta con
  volver a ejecutarlo con un equipo al día, o indicar otro archivo:
  `CA_BUNDLE=cacert.pem ./install.sh`.
- **Paquete de Mozilla**: `curl -fsSLO https://curl.se/ca/cacert.pem`.
- **Síntoma de certificados vencidos**: errores `x509: certificate signed by
  unknown authority` en el registro de nchat, o `FALLA https` en
  `scripts/phone-test.sh`.
- **En la futura app**: el paquete va dentro del APK y se actualiza con cada
  versión.

## Pruebas sin el teléfono

`scripts/phone-test.sh` necesita el teléfono. Una alternativa estudiada, todavía
no implementada, es emular un ARMv7 con kernel 3.0 en `qemu-system-arm`:

- **Cómo**: placa `vexpress-a9` (Cortex-A9, como el Galaxy Fame) con un kernel
  3.0.101 de kernel.org (`vexpress_defconfig`) y un initramfs con los binarios
  estáticos y un `busybox`, con red emulada para DNS y HTTPS.
- **Dificultad**: un kernel 3.0 no compila con un GCC moderno; hace falta una
  toolchain de la época (GCC 4.x) dentro de un contenedor viejo de Debian.
- **Qué prueba**: el runtime de Go y los binarios estáticos frente a las llamadas
  al sistema de un 3.0, que es el punto más frágil.
- **Qué no prueba**: nada de Android (`app_process`, `MediaPlayer`, TermOne
  Plus, `su`).
