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
logo ocupa 13 filas (10 líneas, borde y margen). Desde el 7 de noviembre de 2026
el Fame (serie 4d009ce074228000) está sin sesión y se usa solo por ADB para SMS;
OldieChat vinculado está en el Samsung Galaxy Core 2 SM-G355H (serie
4203ce4abc349100, Android 4.4.2, kernel 3.10, SELinux Enforcing, root con
SuperSU, TermOne Plus 5.7.0/X). Con los dos conectados se usa `ANDROID_SERIAL`.
Repositorio:
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

## Versión 0.2.3 (publicada en GitHub el 7 de noviembre de 2026)

- Rama `main`, etiqueta `v0.2.3` en `90471cd`.
- Tres arreglos: mensajes largos de a 2 líneas con W/S (parche 0013, con
  `redrawwin` porque TermOne Plus no repintaba las filas movidas), salir cierra la
  ventana de TermOne Plus (`wsp`) y los adjuntos descargados se borran al salir.
- Compilada el 2 de noviembre de 2026 (4 min 8 s, `build.log` sin errores):
  `out/oldiechat-terminal-0.2.3-armv7.tar.gz` y `-source.tar.gz`.
- Instalada en el Fame el 7 de noviembre de 2026 y `scripts/phone-test.sh --sound`
  dio "Todo pasó" (el tono sonó). Antes se probó a mano con una compilación de la
  misma fuente: los 3 arreglos funcionan con el teclado abierto y cerrado.
- Fame: bloqueo de pantalla desactivado con root (`lockscreen.disabled=1` en
  `/data/system/locksettings.db`; respaldos `locksettings.db*.orig` en
  `/data/system`). Para pruebas por ADB: `svc power stayon usb`, y volver a
  `svc power stayon false` al terminar.
- `work/nchat/.gotools` (caché Go de 255 MB, del 25/10) no lo crea `build.sh` y
  entra en el paquete de código fuente; revisar si se quita.

## Área 3, etapa 1: seguridad de la sesión (rama `usuarios`, unida a `main`)

- Commit `3470d64` (sobre `main`, 0.2.3). `home/` queda `root:root` con permisos
  700: `install.sh` aplica `chown 0:0` y `chmod 700`, y `oldiechat.sh` lo repite al
  arrancar. Los README (español e inglés) explican cómo desvincular el dispositivo
  desde el teléfono principal si se pierde el teléfono, y ya no tienen la sección
  "adb shell sin root".
- Probado el 7 de noviembre de 2026 en el Fame, solo con `oldiechat.sh` y `home`
  (copiados a mano): `ls -ld` da `root root drwx------`, el shell sin `su` recibe
  "Permission denied" y OldieChat abre autenticado, sin QR (registro de nchat).
  No se entró a Saved Messages.
- `install.sh` completo se probó en el Core 2 en la etapa 2.

## Área 3, etapa 2: actualizar y respaldar (rama `usuarios`, unida a `main`)

- Commits `f19cd38`, `047b5f3`, `c5f69d7` y `3ff81dd`. `VERSION` es `0.2.4-dev`;
  paquete compilado el 7 de noviembre de 2026 (4 min 6 s, sin errores) en
  `out/oldiechat-terminal-0.2.4-dev-armv7.tar.gz`. No hay nada sin compilar.
- `install.sh` actualiza conservando sesión y configuración (la anterior queda
  como `.bak`) y avisa "Versión anterior: X. Instalada: Y." (lee la línea
  `OldieChat X (c)` de `/system/bin/wsp`) o "Instalación nueva".
- `session.sh respaldar | restaurar <archivo>` (en el paquete, se usa desde el
  PC): copia `profiles/`, `history/` y `.config/nchat/version` (sin él nchat no
  abre) con `cat` y `chown`/`chmod` uno por uno; se detiene si OldieChat está
  abierto (`ps`) o si el destino ya tiene sesión. Copia temporal en
  `/data/local/tmp/oldiechat-session` (700), respaldo en `~/Respaldos/oldiechat/`
  (600). README (español e inglés): sección "Actualizar, respaldar y restaurar".
- Revisado en whatsmeow: un respaldo sigue autenticando, pero cuando la otra copia
  se usó, las sesiones Signal y los prekeys avanzan y se pierden mensajes; dos
  copias conectadas se desconectan entre sí (`StreamReplaced`, que nchat solo
  registra en TRACE). Por eso: respaldar justo antes de mudarse y borrar después.
- Samsung con kernel 3.10 (Core 2, `CONFIG_SEC_RESTRICT_FORK`): un programa root en
  `/data` no puede ejecutar otros ("Restricted making process" en el kernel), y
  nchat no lanzaba `audio.sh`. `oldiechat.sh` monta `$D` en `/dev/oldiechat` y
  corre nchat desde ahí (si el montaje falla, desde `$D`). Probado también el
  montaje en el Fame. `phone-test.sh` acepta `MEDIA_STARTED` (4.4 no registra
  `createTrack`).
- Probado el 7 de noviembre de 2026: 0.2.3 instalada en el Core 2 (primera vez en
  4.4, SELinux Enforcing), sesión del Fame respaldada y restaurada, actualización a
  0.2.4-dev encima; autenticó sin QR. `phone-test.sh --sound` dio "Todo pasó" y el
  dueño probó a mano en TermOne Plus 5.7.0/X (copiado del Fame): mensajes,
  archivados, salir, acceso directo, nota de voz y guía.
- La copia del Fame (`home/`) y los respaldos del PC se borraron. El Fame no se
  vuelve a vincular por ahora: se usa solo por ADB para SMS.
- `usuarios` se unió a `main` por avance rápido el 7 de noviembre de 2026, sin
  publicar (ver etapa 10).

## Área 3, etapa 10: formato en el Core 2 (rama `usuarios`, unida a `main`)

- Commits `d5dc8ae` y `b7947d6`. `VERSION` sigue en `0.2.4-dev`; compilada el
  7 de noviembre de 2026 (4 min 5 s, sin errores). No hay nada sin compilar ni
  sin probar. Unida a `main` por avance rápido, sin publicar ni subir.
- Causa: en Android 4.4, SuperSU corre `su` por `daemonsu`, que le da a nchat
  una terminal propia y le copia el tamaño de TermOne Plus solo al arrancar.
  Al abrir o cerrar el teclado nchat seguía con el tamaño anterior (bordes y
  guía viejos, y el toque para abrir el teclado caía en otra fila).
- Parche 0014 (`src/uicontroller.cpp`, 16 líneas): si existe `OLDIECHAT_TTY`,
  `GetKey` (la espera de 50 ms que nchat ya tiene) copia el tamaño de esa
  terminal a la propia y nchat recibe `KEY_RESIZE`. `wsp` pasa
  `OLDIECHAT_TTY=/proc/$$/fd/0`. Probado a mano en el Core 2: lista, guía y
  abrir el teclado con dos toques.
- `install.sh` se detiene si OldieChat está abierto (como `session.sh`).
- Revisado por `ps` en el Core 2: con Vol. abajo + S, Atrás ("Envía TAB al
  terminal") y "Cerrar ventana" no queda nada. Con Atrás en "Cerrar la actividad
  y conservar las sesiones" (como estaba el Core 2) o al quitar TermOne Plus de
  recientes, la sesión y nchat siguen vivos en segundo plano: no es `daemonsu`,
  es TermOne Plus. El README ya pide Atrás = "Envía TAB al terminal"; el Core 2
  quedó así.

## Estado al cierre del 7 de noviembre de 2026

- Último cierre del día: rama actual `sms` (Área 5, etapa 1 hecha). Nada subido a
  GitHub. Lo que sigue en `main` queda como se describe abajo.
- Rama actual: `main`. `origin/main` está en `1378832` (la unión de `usuarios`,
  subida por el dueño); `CLAUDE.md` y este cierre quedan solo en local.
  `VERSION` es `0.2.4-dev`.
- Compilado el 7/11 (4 min 5 s, sin errores) con `out/` al día; instalado en el
  Core 2 y probado a mano. Nada sin compilar ni sin probar.
- `CLAUDE.md` actualizado: 0.2.3 publicada, teléfonos (Fame solo ADB, Core 2 de
  uso diario), TermOne Plus con Atrás en "Envía TAB al terminal", reglas de
  terminal en mantenimiento y de publicar.

## Pendientes para la 0.2.4 (anotados, sin hacer)

- Emoji: en el Core 2 salen a color y `glyphs.txt` es del Fame. Evaluar que
  `install.sh` genere `glyphs.txt` en cada teléfono con `scripts/glyphs.sh`
  (avisar si exige instalar algo más en el PC) y si se puede preferir la fuente
  en blanco y negro sin agregar peso; si no, se queda a color.
- `phone-test.sh`: probar el audio igual que lo lanza OldieChat, desde un nchat
  que corre como root (habría detectado la restricción de Samsung).
- `audio.log` anota la hora en UTC: `date` de Android no entiende la ruta de
  archivo que `oldiechat.sh` pone en `TZ`.
- Al publicar: `VERSION` 0.2.4, `CHANGELOG.md`, recompilar, `install.sh` y
  `phone-test.sh --sound` en el Core 2, y prueba a mano.

## Área 5: OldieChat SMS (rama `sms`, no se une a `main`)

- `main` se unió dentro de `sms` el 7 de noviembre de 2026 (sin subir).
- Etapa 0, hecha en el Fame solo por ADB: `scripts/sms-test.sh` lee el inbox cada
  2 s, responde a un número con un menú ficticio y envía con
  `cl.oldiechat.sms.SmsSend` (`player/`) como uid radio (1001); desde root sin
  paquete Android rechaza el envío. 7 comandos respondidos en un SMS cada uno
  (29 a 71 caracteres); detección 1-3 s, total 2-3 s hasta que Android lo entrega.
  No se midió la llegada al teléfono del dueño. `player.jar` está en el Fame.
- Etapa 1, diseño aprobado: `docs/SMS_BRIDGE.md`, con los cambios y respuestas del
  dueño. Sin código. Commits `dae8454` (diseño), `6e0da82` (unión de `main`) y
  `511a925` (cambios del dueño).
- `CLAUDE.md` en `sms` tiene la regla del costo actualizada (`4ac518a`): dos líneas
  con SMS, 500 al mes cada una en uso normal y 1.000 en intenso, condiciones de las
  cuatro compañías sin recomendar ninguna. **`main` todavía tiene la regla vieja**:
  falta decidir si se copia esa línea a `main`.
- Nada que compilar ni probar: la etapa 1 es solo diseño.

## Qué sigue

- Área 5: la siguiente etapa la indica el dueño. El Fame se vincula como
  dispositivo nuevo en el Área 1, etapa 7. Decidir si la regla del costo de
  `CLAUDE.md` se copia a `main`.
- Área 3: etapas 1, 2 y 10 hechas y unidas a `main`. La etapa 3 (logo grande al
  iniciar) pasó a la app.
- Pendientes de la terminal 0.2.4 (arriba): emoji y `glyphs.txt`, `phone-test.sh`
  con el audio desde nchat, hora local en `audio.log`. Se unen a `main` como
  0.2.4-dev; la 0.2.4 se publica solo si whatsmeow lo obliga o hace falta para
  usuarios (regla en `CLAUDE.md`).

## Archivos

| Ruta | Para qué |
| --- | --- |
| `build.sh`, `Dockerfile.armv7`, `versions.env`, `VERSION` | compilación |
| `nchat/patches/` | parches a nchat, numerados; la tabla está en el README |
| `nchat/vendor/` | dependencias Go de nchat (`scripts/vendor-go.sh`) |
| `go/patches/` | parches propios al runtime de Go: el de musl (Go PR #69325) |
| `engine/` | motor Go: `audio/oggopus`, `netcfg`, `tz`, `wa`, `cmd/` |
| `player/` | Java por `app_process`: reproductor, `GlyphProbe` y `SmsSend` |
| `phone/` | lo que va al teléfono: `oldiechat.sh`, `audio.sh`, `install.sh`, ícono, `config/`, `fonts/`, `licenses/` |
| `scripts/` | `phone-test.sh`, `glyphs.sh`/`glyphs.py`, `make-emoji-font.sh`, `make-icon.sh`, `check-go-version.sh`, `update-whatsmeow.sh`, `vendor-go.sh`, `sms-test.sh` |
| `tests/data/` | audio de prueba |
| `docs/` | este archivo, la arquitectura de la app y el puente SMS (`SMS_BRIDGE.md`) |
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
