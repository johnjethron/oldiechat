# Estado del proyecto

Resumen para retomar el trabajo. Léelo antes de empezar, junto con `CLAUDE.md`.

## Qué es

OldieChat es un cliente de mensajería compatible con WhatsApp para teléfonos
Android antiguos. Hoy existe **OldieChat terminal**: nchat (solo WhatsApp)
compilado como binario estático ARMv7, con parches propios, para usarse en
TermOne Plus en un Android 4.x con root. La siguiente etapa es una app Android en
Java que reutiliza el motor (`engine/`); su arquitectura está propuesta en
`docs/APP_ARCHITECTURE.md` y la interfaz todavía no se empieza.

Teléfono de pruebas: Samsung Galaxy Fame GT-S6810L, Android 4.1.2, kernel 3.0,
Cortex-A9, root con SuperSU, conectado por ADB. Repositorio:
github.com/johnjethron/oldiechat (lo publica el dueño, no Claude).

## Qué está hecho (versión en `VERSION`)

- Compilación reproducible (`build.sh`) en un contenedor Alpine armv7 con qemu:
  versiones y checksums en `versions.env`, dependencias Go guardadas, sin
  internet para la parte Go.
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

## Archivos

| Ruta | Para qué |
| --- | --- |
| `build.sh`, `Dockerfile.armv7`, `versions.env`, `VERSION` | compilación |
| `nchat/patches/` | parches a nchat, numerados; la tabla está en el README |
| `nchat/vendor/` | dependencias Go de nchat (`scripts/vendor-go.sh`) |
| `go/patches/` | parches propios al runtime de Go (vacío) |
| `engine/` | motor Go: `audio/oggopus`, `netcfg`, `tz`, `wa`, `cmd/` |
| `player/` | Java por `app_process`: reproductor y `GlyphProbe` |
| `phone/` | lo que va al teléfono: `oldiechat.sh`, `audio.sh`, `install.sh`, ícono, `config/`, `fonts/` |
| `scripts/` | `phone-test.sh`, `glyphs.sh`/`glyphs.py`, `make-emoji-font.sh`, `make-icon.py`, `check-go-version.sh`, `vendor-go.sh` |
| `tests/data/` | audio de prueba |
| `docs/` | este archivo y la arquitectura de la app |
| `work/`, `out/` | generados, fuera de git |

## Cómo se trabaja

- Compilar: `./build.sh` (lento, emulado). Instalar:
  `out/oldiechat-terminal-<v>-armv7/install.sh`. Probar:
  `scripts/phone-test.sh --sound`.
- Si cambian las fuentes del teléfono: `scripts/glyphs.sh` (unos 9 minutos).
- Registros en el teléfono: `home/.config/nchat/log.txt*` (6 sesiones) y
  `home/audio.log`.
- Las pruebas de interfaz las hace el dueño en el teléfono: no se inyectan teclas
  por ADB en sus conversaciones reales (ver `CLAUDE.md`).
- Antes de publicar: `MAINTAINING.md` (pasos y plan de contingencia).
