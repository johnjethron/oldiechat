# Changelog

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
