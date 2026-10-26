# Estado del proyecto

Resumen para retomar el trabajo. Léelo antes de empezar, junto con `CLAUDE.md`.

## Qué es

OldieChat es un cliente de mensajería compatible con WhatsApp para teléfonos
Android antiguos. Hoy existe **OldieChat terminal**: nchat (solo WhatsApp)
compilado como binario estático ARMv7, con parches propios, para usarse en
TermOne Plus en un Android 4.x con root. La siguiente etapa es una app Android en
Java que reutiliza el motor (`engine/`); su arquitectura está propuesta en
`docs/APP_ARCHITECTURE.md` y la interfaz todavía no se empieza.

Teléfono de pruebas: Samsung Galaxy Fame GT-S6810L, Android 4.1.2, kernel 3.0.15,
Cortex-A9, root con SuperSU, conectado por ADB. Repositorio:
github.com/johnjethron/oldiechat (lo publica el dueño, no Claude).

## Qué está hecho (versión en `VERSION`)

- Compilación reproducible (`build.sh`) en un contenedor Alpine armv7 con qemu:
  versiones y checksums en `versions.env`, dependencias Go guardadas, sin
  internet para la parte Go. Go 1.26.10 con el parche de musl propio
  (`go/patches/`, Go PR #69325).
- whatsmeow al día sin esperar a nchat: `scripts/update-whatsmeow.sh` fija
  `WHATSMEOW_COMMIT` y actualiza la terminal y el motor en un solo paso
  (hoy b2b1e71, 17 de octubre de 2026).
- Instalación por ADB (`phone/install.sh`): programa en `/data/local/tmp/oldiechat`,
  DNS y certificados en `/system`, comando `wsp`, ícono para Nova Launcher,
  fuente Noto Emoji en `/system/fonts` (respaldo `.orig` de las listas de fuentes).
- Atajos mínimos: Vol. arriba + W/S (mensajes), A/D (chats, con borrador), Enter
  (enviar; con el campo vacío, escuchar un audio seleccionado), Vol. abajo + A
  (archivados), G (guía), S (volver o salir con confirmación). Todos los demás
  atajos de nchat están desactivados en `phone/config/key.conf`.
- Toque activo: tocar un nombre abre el chat; dos toques abajo abren el teclado.
- Cursor siempre al final del texto (`entry_cursor_end`).
- Notas de voz: Opus → WAV (`engine/audio/oggopus`) y reproducción con el
  MediaPlayer de Android vía `app_process` (`player/`), etiqueta `audio mm.ss`.
- Archivados completos, hora local, conversación con colores parejos.
- Glifos y anchos medidos en el teléfono (`GlyphProbe` → `phone/config/glyphs.txt`):
  nchat usa los anchos de la terminal y reemplaza lo que no se dibuja bien.
- Motor reutilizable `engine/` (whatsmeow, audio, DNS y certificados sin root,
  zona horaria, protocolo JSON por stdin/stdout); compila y `selftest` pasa en el
  teléfono, **nunca se conectó al servidor**.

## En curso (0.2.2, sin publicar)

- `VERSION` dice 0.2.2. Lo del Área 1 (Go 1.26.10, parche de musl propio,
  whatsmeow b2b1e71, `update-whatsmeow.sh`) está en `main` (rama `motor`, ya
  unida): se compiló e instaló en el Fame y `phone-test.sh --sound` pasó, con el
  paquete todavía llamado 0.2.1 en `out/`.
- Rama `usuarios` (Área 3), **sin compilar**: etiquetas cortas de adjuntos en el
  parche `0010-attachment-labels.patch` (`imagen`, `video`, `sticker`,
  `documento pdf`; commits 4707d31 y 272a556). Falta anotarlas en `CHANGELOG.md`.
- Lo siguiente: logo ASCII en la guía (Área 3, etapa 5). Después compilar,
  probar en el Fame y publicar la 0.2.2 (pasos en `MAINTAINING.md`).

## Archivos

| Ruta | Para qué |
| --- | --- |
| `build.sh`, `Dockerfile.armv7`, `versions.env`, `VERSION` | compilación |
| `nchat/patches/` | parches a nchat, numerados; la tabla está en el README |
| `nchat/vendor/` | dependencias Go de nchat (`scripts/vendor-go.sh`) |
| `go/patches/` | parches propios al runtime de Go: el de musl (Go PR #69325) |
| `engine/` | motor Go: `audio/oggopus`, `netcfg`, `tz`, `wa`, `cmd/` |
| `player/` | Java por `app_process`: reproductor y `GlyphProbe` |
| `phone/` | lo que va al teléfono: `oldiechat.sh`, `audio.sh`, `install.sh`, ícono, `config/`, `fonts/`, `licenses/` |
| `scripts/` | `phone-test.sh`, `glyphs.sh`/`glyphs.py`, `make-emoji-font.sh`, `make-icon.sh`, `check-go-version.sh`, `update-whatsmeow.sh`, `vendor-go.sh` |
| `tests/data/` | audio de prueba |
| `docs/` | este archivo y la arquitectura de la app |
| `work/`, `out/` | generados, fuera de git |

## Cómo se trabaja

- Compilar: `./build.sh` (unos 55 minutos, emulado). Instalar:
  `out/oldiechat-terminal-<v>-armv7/install.sh`. Probar:
  `scripts/phone-test.sh --sound`.
- Actualizar whatsmeow: `scripts/update-whatsmeow.sh` (con internet);
  `scripts/check-go-version.sh` dice cuántos commits vamos atrasados.
- Si cambian las fuentes del teléfono: `scripts/glyphs.sh` (unos 9 minutos).
- Registros en el teléfono: `home/.config/nchat/log.txt*` (6 sesiones) y
  `home/audio.log`.
- Las pruebas de interfaz las hace el dueño en el teléfono: no se inyectan teclas
  por ADB en sus conversaciones reales (ver `CLAUDE.md`).
- Antes de publicar: `MAINTAINING.md` (pasos y plan de contingencia).
