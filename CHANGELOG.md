# Changelog

## 0.2.0

- **Audio**: las notas de voz no sonaban después de migrar desde
  `/data/local/tmp/nchat`, porque nchat guarda rutas absolutas de los adjuntos.
  `install.sh` deja la ruta vieja como enlace. El reproductor ya no muere si se
  cierra la sesión que lo lanzó, y cada paso queda en `home/audio.log`.
- **Archivados**: se listan todos los chats archivados guardados, no solo los que
  tenían mensajes recientes.
- **Atajos simples**: Volumen arriba + W/S/A/D para moverse, Enter para enviar o
  escuchar un audio, Volumen abajo + A/B/G/S para archivados, buscar, guía y
  salir. Guía corta en español en el teléfono (Volumen abajo + G).
- **Compatibilidad a futuro**: versiones exactas y checksums en `versions.env`,
  dependencias Go guardadas en el repositorio (`go mod vendor`), paquete de
  código fuente en cada versión, `scripts/check-go-version.sh`,
  `scripts/phone-test.sh` y `MAINTAINING.md` con el plan de contingencia.
- **Motor reutilizable** (`engine/`): conversión de audio, DNS y certificados sin
  root, zona horaria y núcleo de mensajería sobre whatsmeow, independiente de
  nchat. Arquitectura de la futura app en `docs/APP_ARCHITECTURE.md`.
- nchat registra cada intento de abrir un adjunto y el comando que lanza.

## 0.1.0 — primera versión de OldieChat terminal

- nchat (solo WhatsApp) como binario estático musl para ARMv7, sin depender de
  Bionic, probado en Android 4.1.2 (Samsung Galaxy Fame GT-S6810L).
- Instalador por ADB: programa, configuración, DNS, certificados, comando `wsp`
  e ícono para el acceso directo.
- Interfaz para pantalla de 3,5": atajos con Fn/Ctrl en los botones de volumen,
  elegir chat tocando la lista, doble toque en el área de escritura para el
  teclado.
- Vista de chats archivados (Fn+9) y corrección de archivados que reaparecían.
- Notas de voz: conversión Opus a WAV (Go + libopus) y reproducción en segundo
  plano con el MediaPlayer de Android (Ctrl+9 / Ctrl+0).
- Zona horaria del teléfono y filtro de emoji para la fuente de Android 4.x.
