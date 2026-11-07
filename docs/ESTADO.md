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
Cortex-A9, root con SuperSU, conectado por ADB. Terminal en TermOne Plus con el
teclado abierto: 53 columnas y 15 filas (`echo $COLUMNS $LINES`); la guía con el
logo ocupa 13 filas (10 líneas, borde y margen). Repositorio:
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

## Versión 0.2.2 (publicada en GitHub)

- `main`, etiqueta `v0.2.2`; las ramas `motor` y `usuarios` ya están unidas.
  No hay nada sin compilar ni sin probar.
- `CLAUDE.md` tiene los productos nuevos (OldieChat App y OldieChat SMS), los 5
  principios con el minimalismo primero y las reglas de ahorro de uso.
- Incluye Go 1.26.10 con el parche de musl propio, whatsmeow b2b1e71, etiquetas
  cortas de adjuntos y `link dominio`, logo en la guía con una línea en blanco
  debajo, ícono nuevo y `wsp` que comprueba SuperSU. `wsp --version` muestra
  versión (de `VERSION`, que va en el paquete), autor y licencia sin pedir root.
- Paquetes en `out/`: nchat compilado el 26/10; los `.tar.gz` se rearmaron el
  29/10 sin recompilar, por cambios solo en `install.sh`, `guide.txt` y `VERSION`.
- Instalada en el Fame: `phone-test.sh --sound` dio "Todo pasó" (el tono sonó) y
  el dueño probó a mano mensajes, audios, adjuntos, enlaces, guía, `wsp --version`
  e ícono en Nova.
- `work/nchat/.gotools` (caché Go de 255 MB, del 25/10) no lo crea `build.sh` y
  entra en el paquete de código fuente; revisar si se quita.

## Versión 0.2.3 (lista para publicar)

- Rama `main` (la rama `usuarios` quedó unida), etiqueta local `v0.2.3`. Nada está
  subido a GitHub: lo publica el dueño.
- Tres arreglos: mensajes largos de a 2 líneas con W/S (parche 0013, con
  `redrawwin` porque TermOne Plus no repintaba las filas movidas), salir cierra la
  ventana de TermOne Plus (`wsp`) y los adjuntos descargados se borran al salir.
- Compilada el 2 de noviembre de 2026 (4 min 8 s, `build.log` sin errores):
  `out/oldiechat-terminal-0.2.3-armv7.tar.gz` y `-source.tar.gz`.
- Instalada en el Fame el 7 de noviembre de 2026 y `scripts/phone-test.sh --sound`
  dio "Todo pasó" (el tono sonó). Antes se probó a mano con una compilación de la
  misma fuente: los 3 arreglos funcionan con el teclado abierto y cerrado.
- **Falta**: pasar `MAINTAINING.md` y subir a GitHub (lo hace el dueño).
- Fame: bloqueo de pantalla desactivado con root (`lockscreen.disabled=1` en
  `/data/system/locksettings.db`; respaldos `locksettings.db*.orig` en
  `/data/system`). Para pruebas por ADB: `svc power stayon usb`, y volver a
  `svc power stayon false` al terminar.
- `work/nchat/.gotools` (caché Go de 255 MB, del 25/10) no lo crea `build.sh` y
  entra en el paquete de código fuente; revisar si se quita.

## Área 3, etapa 1: seguridad de la sesión (rama `usuarios`, sin unir a `main`)

- Commit `3470d64` (sobre `main`, 0.2.3). `home/` queda `root:root` con permisos
  700: `install.sh` aplica `chown 0:0` y `chmod 700`, y `oldiechat.sh` lo repite al
  arrancar. Los README (español e inglés) explican cómo desvincular el dispositivo
  desde el teléfono principal si se pierde el teléfono, y ya no tienen la sección
  "adb shell sin root".
- Probado el 7 de noviembre de 2026 en el Fame, solo con `oldiechat.sh` y `home`
  (copiados a mano): `ls -ld` da `root root drwx------`, el shell sin `su` recibe
  "Permission denied" y OldieChat abre autenticado, sin QR (registro de nchat).
  No se entró a Saved Messages.
- **Falta**: probar `install.sh` completo con esta versión (se hará en el Core 2,
  etapa 2), compilar un paquete nuevo si se quiere publicar (no cambió el binario,
  solo scripts y README) y decidir cuándo se une `usuarios` a `main`.
- El Core 2 (serie 4203ce4abc349100, rooteado) no se tocó; OldieChat se instala ahí
  en la etapa 2. Con los dos conectados se usa `ANDROID_SERIAL` (Fame
  4d009ce074228000).

## Otras ramas

- `CLAUDE.md`: las dos contradicciones quedaron resueltas en `main` (`c819f8c`: Fame
  solo por ADB, sin Linux Mint).
- Rama `sms` (5 commits sobre `ce9dd21`, **sin unir a `main`**): Área 5, etapa 0
  hecha en el Fame solo por ADB. `scripts/sms-test.sh` lee el inbox cada 2 s,
  responde con un menú ficticio y envía con `cl.oldiechat.sms.SmsSend` (`player/`)
  como uid radio. 7 comandos respondidos en un SMS cada uno; total 2-3 s hasta
  que Android lo entrega. No se midió la llegada al teléfono del dueño.
  Su `docs/ESTADO.md` tiene el detalle.

## Qué sigue

- Publicar la 0.2.3 (comandos del dueño). Esa publicación no incluye `usuarios`.
- Decidir si la rama `sms` se une a `main` y qué parte de la prueba se conserva;
  Área 5, etapa 1 la indica el dueño.
- Área 3: la etapa 1 está hecha en la rama `usuarios`; sigue la etapa 2 (instalar
  en el Core 2). La etapa 3 (logo grande al iniciar) pasó a la app.
- El Core 2 SM-G355H llega la primera semana de noviembre de 2026.

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

- Compilar: `./build.sh` (4 min 10 s con la caché de `work/`, medido el 2 de noviembre de 2026 en el PC con CachyOS; emulado). Instalar:
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
