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
el Samsung Galaxy Core 2 SM-G355H (serie 4203ce4abc349100) tenía la terminal
vinculada en Android 4.4.2. Desde el 9 de noviembre de 2026 tiene LineageOS 15.1
Go (Android 8.1, 32 bits) y es el teléfono de prueba de Android 8.1 (motor por ADB
y la futura app); la terminal no se prueba ahí y el Android 4.4 con su sesión
queda solo en el respaldo TWRP `~/Respaldos/core2-stock-oldiechat`. Detalle y
prohibiciones en `CLAUDE.md`. Con los dos conectados se usa `adb -s` con la serie.
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
  teléfono; se conectó por primera vez el 7 de noviembre de 2026 (Área 1, etapa 7).

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

## Área 1, etapa 7: conectar el motor a WhatsApp (rama `motor`)

- Rama `motor` creada desde `main` el 7 de noviembre de 2026, sin subir. Antes,
  en `main`: la regla del costo de `sms` copiada con cherry-pick (`0a169e1`) y la
  regla de explicar el trabajo estructural en `CLAUDE.md` (`f292803`).
- `engine/wa`: `store.DeviceProps.Os = "OldieChat"` (`4e5922b`). En el iPhone el
  Fame igual aparece como "Otro dispositivo" con ícono "?"; queda así por ahora.
- Punto 1 completo en el Fame, sin su, en `/data/local/tmp/oldiechat-engine/`
  (permisos 700, sesión en `data/`): vincula con código de 8 caracteres como
  dispositivo nuevo (el Core 2 sigue vinculado con la terminal), retoma sin
  código al reiniciar, envía, recibe, distingue el principal (remitente con
  Device 0) y no envía confirmaciones de lectura (solo el recibo de entrega).
  Se envió solo a Saved Messages (chat con uno mismo).
- El primer "hola" después de vincular no llegó (sin evento y 0 pendientes al
  reiniciar); causa sin confirmar. Vigilarlo en las próximas pruebas.
- Para el punto 3: los chats llegan con LID (`...@lid`); el número viene aparte
  (`peer_recipient_pn`) y hay que convertirlo. Los mensajes que no son texto ni
  audio no se descartan: se emiten con una etiqueta corta como en la terminal
  ("imagen 45 KB", "video", "documento pdf", "sticker").
- Puntos 1 a 5 hechos en `motor` el 7 de noviembre de 2026 (commits `80cedf6` a
  `fa100cb`). Punto 6 (una sola vinculación) no se implementa: la terminal sigue
  con su propia sesión; app y puerta de enlace compartirán la del motor.
- Evento `message` con `device` (0 = principal).
- Órdenes nuevas: `logout` (desvincula, vacía chats y mensajes guardados, emite
  `logged_out` y termina), `chats` (`kind` `people` o `groups`: chat, nombre,
  hora del último mensaje y no leídos) y `messages` (mensajes de un chat desde la
  consulta anterior; en la primera, todos los guardados).
- Tablas propias en `session.db` (`engine/wa/store.go`): `oc_message` (tope de 50
  por chat, se borran los más viejos) y `oc_chat` (nombre de grupo y último
  mensaje entregado). El LID se cambia por el número cuando se conoce. Los
  mensajes del historial no cuentan como no leídos. Lo enviado con `send` también
  se guarda. Estados y canales no se guardan ni se emiten; reacciones tampoco.
  El nombre de grupo se pide una vez al servidor y se actualiza con el evento de
  cambio de nombre. Cuando el principal cierra la sesión también se vacían.
- Etiquetas: `imagen N KB`, `video N KB`, `gif N KB`, `sticker`,
  `documento <ext> N KB`, `ubicacion`, `contacto`, `link <dominio>`; el texto de
  imagen, video o documento va después de `: `.
- `media/` (WAV de audios) se borra al arrancar y al cerrar el motor.
- Historial inicial: `FullSyncDaysLimit` 1, `FullSyncSizeMbLimit` 1 e
  `InitialSyncMaxMessagesPerChat` 50.
- `engine/glyphs` y opción `--glyphs <archivo>|sms` en `run`: pantalla aplica solo
  las líneas R de `glyphs.txt`; SMS deja GSM de 7 bits (quita tildes que GSM no
  tiene, conserva ñ, é, ¿), quita emoji sin reemplazo, y un mensaje que queda
  vacío no se emite. `golang.org/x/text` pasó a dependencia directa (ya estaba en
  `vendor/`).
- README (español e inglés): sección "Plazos de WhatsApp" / "WhatsApp time limits"
  con el texto del dueño (`86c8788`).
- Probado en el Fame el 7 de noviembre de 2026, sin su, solo enviando a Saved
  Messages: `chats` y `messages` (la segunda consulta vuelve vacía), emoji en los
  dos modos, `logout` (tablas vacías y `need_pairing` al abrir) y vincular de nuevo
  con código. Historial recibido: 31 chats de personas (395 mensajes) y 7 grupos
  (14 mensajes, todos con nombre); ningún chat pasó de 50; el mensaje más antiguo
  era de unas 3 semanas antes (el límite de 1 día no lo acortó).
- Decisión del dueño: la app y el motor vinculan solo con el código de 8
  caracteres, sin QR. La orden `pair_qr` se quitó a propósito (`fa100cb`); su
  código está en el commit `f2b76b2`, por si WhatsApp deja de permitir el código.
  La terminal no cambia: sigue vinculando con el QR de nchat.
- Sin probar: cambio de nombre de grupo, etiquetas `ubicacion` y `contacto`, y el
  motor de `fa100cb` (sin `pair_qr`) en el teléfono: el Fame tiene la compilación
  anterior, que todavía incluye `pair_qr`.
- Pendientes anotados (sin código): modo pantalla de `engine/glyphs`: los emoji
  sin línea R (👍🏽) y el selector de variante que queda tras un reemplazo (`<3` +
  U+FE0F) pasan tal cual; se decide en la app, según su fuente.
- Pendiente para el Área 1, etapa 5: la opción de días del historial reciente
  (`RecentSyncDaysLimit`), si la sincronización usa mucha memoria.
- El primer "hola" después de la primera vinculación no llegó; causa sin
  confirmar. Sigue en vigilancia.

## Otras ramas

- `CLAUDE.md`: las dos contradicciones quedaron resueltas en `main` (`c819f8c`: Fame
  solo por ADB, sin Linux Mint).
- Rama `sms` (5 commits sobre `ce9dd21`; recibió `main` y `motor`, pero **no está
  unida a `main`**, ver Área 5): Área 5, etapa 0 hecha en el Fame solo por ADB. Su
  detalle está en la sección Área 5.

## Área 5: OldieChat SMS (rama `sms`: ya tiene `main` y `motor`; todavía no se une a `main`)

- `main` (que ya incluía `motor`) se unió dentro de `sms` el 7 de noviembre de 2026
  (`1a5e3b0`, sin subir). `sms` todavía no se une a `main`.
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
  cuatro compañías sin recomendar ninguna. `main` ya tiene la misma regla
  (`CLAUDE.md` es igual en las dos ramas).
- Nada que compilar ni probar: la etapa 1 es solo diseño.
- Etapa 2a, hecha y probada en el Fame el 8 de noviembre de 2026 (commits `ef4042e`
  a `c5d689e`): `scripts/sms-bridge.sh` reemplaza a `sms-test.sh`. Comandos: llamada
  perdida o `0` (menú de 9 personas con no leídos, sin grupos ni segunda página),
  `n` (mensajes nuevos en 1 SMS; si no hay, `[SIN NUEVOS]`), `n texto`, texto solo
  (a la última persona abierta o escrita) y `a`. Todo lo demás, incluidos `00`, `g`
  y `gn` (etapa 2b), responde el menú. Silencio si el envío sale bien; el siguiente
  menú trae `[OK] Nombre`. Respuestas siempre al número del dueño, GSM con
  `--glyphs sms`, 30 SMS por hora. Opciones de prueba: `-t` (SMS al registro con
  septetos) y `-s` (WhatsApp solo a Saved Messages).
- Cómo corre: como shell (`adb shell sh /data/local/tmp/sms-bridge.sh [-t] [-s]
  +569...`), con el motor como coproceso (proceso hijo unido por tuberías) en los
  descriptores 3 y 4. Un solo `su` corre la parte root (`--poll`), que consulta
  inbox y llamadas cada 2 s y pasa lo nuevo por otra tubería; termina sola si el
  script muere. Envía con `su 1001` y `SmsSend`. El motor no puede ir con `su 2000`:
  queda sin el grupo `inet` y sin red.
- mksh R40 del Fame: sin `read -t`, sin `$'..'` en reemplazos, la barra invertida
  escapa también dentro de patrones entre comillas, y el último comando de una
  tubería corre en un subshell. El JSON se lee cambiando cada barra por un carácter
  de control antes de cortar.
- Aceptado para la 2a: sin `read -t`, si el motor se cuelga el script queda esperando.
- Pruebas: con `-t -s`, 36 SMS falsos insertados con `content insert` (funciona en
  4.1) y ya borrados, más una llamada perdida falsa, también borrada; todo pasó.
  Prueba final real con `-s`: 4 SMS enviados (menú, `1`, menú con `[OK]`, `a`) y
  `1 prueba` llegó a Saved Messages; cada respuesta salió 2-3 s después del SMS.
  Memoria con el motor y el puente: MemFree 13 MB, Cached 199 MB, motor 13 MB RSS.
- Anotado, sin arreglar: `[OK]` está en memoria y se pierde al reiniciar el puente
  (decisión del dueño: queda así). Un SMS con saltos de línea llega cortado a la
  primera línea. Leer un
  chat no lo marca como leído en WhatsApp (el motor no llama a `MarkRead`).
- Etapa 2b, parte 1 (8 de noviembre de 2026, commits `2a31dca` y `de6b99a`):
  `00` envía en 1 SMS lo nuevo de las 9 personas del menú, cada línea con su número
  (`3 Ana: hola`), del más antiguo al más nuevo; si no cabe, quedan los más recientes;
  sin nada nuevo, `[SIN NUEVOS]` solo. `00` cuenta como menú (fija los números). `g`:
  menú de hasta 9 grupos con `[PIE]`; `gn`: los últimos 3 mensajes nuevos del grupo con
  el nombre de pila de quien escribe (o su número); `gn texto` escribe al grupo y no
  cambia la última persona. Probado en el Fame con `-t -s` y SMS falsos; los nombres en
  grupos, con un JSON falso (no había mensajes nuevos de otros en grupos).
  `[NO SE ENVIO] Nombre` probado con `-s` y el número `+56@993359016`: el chat propio
  queda inválido y el motor responde `unknown server`; pasó con persona y grupo.
  Archivados (`c9ebe78`): la orden `chats` del motor trae `"archived":true` en los
  chats archivados (de `ChatSettings` de whatsmeow; la app lo usará para su pantalla de
  archivados) y el puente los salta en el menú de personas, en `00` y en `g`; no hay
  comando para verlos. Compilado el 8/11 a las 19:07 (`out/engine/`, sin errores) e
  instalado en el Fame: retomó la sesión sin pedir código; de 7 grupos, 6 archivados,
  y `g` mostró solo el no archivado; `0` y `00` mostraron personas (ninguna de las 33
  está archivada); el salto de una persona archivada se probó con un JSON falso.
  El límite de 30 SMS por hora se guarda en `sms-bridge-sent` (junto al script) y
  sobrevive a un reinicio (`da51978`, probado con -t -s); `[OK]` sigue en memoria.
- Etapa 2b, parte 2 (11 de noviembre de 2026, sin SMS reales por presupuesto). Pruebas
  con `-t`, SMS falsos y un motor falso (script que responde `chats`, `messages` y `send`
  con mensajes escritos a mano), en `/data/local/tmp/ft/` del Fame, ya borrado.
  - Modo conversación (`8928b77`): al abrir (`n`) o escribir a una persona (`n texto`,
    `texto`), cada 20 s se pide lo nuevo de esa persona y se reenvía sin los mensajes
    propios; termina con 10 minutos sin SMS del dueño o con un menú (`0`, `00`, `g`).
    La consulta root manda `tic` cada 2 s y eso marca el tiempo. Probado: reenvío,
    propios saltados, `texto` en silencio, cierre por tiempo (acortado a 60 s en la
    copia) y cierre con `0`. Si el dueño escribe sin abrir, lo pendiente de esa persona
    llega en el siguiente ciclo.
  - Aviso de enviado: `SmsSend` divide en partes, espera el aviso de enviado (60 s) y
    escribe `enviado` o `error <código>`; pide también el informe de entrega y lo espera
    10 s (`entregado`, `no entregado <estado>` o `sin informe de entrega`), solo para el
    registro. Sin Context, pide los `PendingIntent` y registra el receptor directo en el
    ActivityManager por reflexión, a nombre de `com.android.phone` (uid 1001). El puente
    reintenta cada minuto un SMS con `error` y lo descarta a los 10 minutos; las fallas
    no cuentan para el límite de 30. Mensajes del modo conversación: hasta 3 partes
    (459 septetos) y `..` al cortar.
  - Como uid 1001, Dalvik no puede crear la caché de un `player.jar` nuevo
    (`/data/dalvik-cache`) y `app_process` se cae: la parte root del puente corre
    `SmsSend` sin argumentos al arrancar, que solo crea la caché.
  - Probado: `SmsSend` en el Fame en modo avión (radio apagada, sin enviar nada) con un
    texto de 2 partes respondió `error 2` (radio apagada); el reintento, el descarte y el
    mensaje de 459 septetos, con la copia del puente que lee el resultado de un archivo.
  - Queda para cuando haya saldo: un envío real con `-s` (`enviado` y `entregado` en el
    registro, que el teléfono del dueño una las 3 partes), saber si el informe de
    entrega se cobra en la línea de la puerta de enlace (si se cobra, se quita), una
    falla real sin señal y `SmsSend` en Android 8.1 (Core 2, la reflexión cambia de
    firma entre versiones).
  - Aviso de 14 días: el filtro del motor deja pasar los mensajes propios enviados desde
    el principal (`"from_me":true,"device":0`) y el puente guarda su hora en
    `sms-bridge-main` (junto al script; si no existe, cuenta desde el primer arranque).
    Desde el día 12, la siguiente respuesta pedida (la que pasa por `pre`: menús, `n`,
    `gn`, `00`, `[NO SE ENVIO]`) empieza con `[ABRE WHATSAPP]`, una vez al día. Al
    arrancar, la terminal muestra hace cuántos días se usó el principal. Probado con el
    motor falso: aviso en el primer menú y no en el segundo; un mensaje propio del
    dispositivo 3 no cuenta; uno del dispositivo 0 actualiza la hora.
  - `00` se quitó (cambio de diseño del dueño, 11/11): un `00` responde el menú para que no
    vaya como texto a la última persona. `Nada nuevo` va siempre con nombre. Probado con
    `-t -s`, motor falso y SMS falsos (borrados).
  - SMS al mes de una persona normal, sin `00` (cálculo, no un mes real): tráfico real del
    dueño, del historial del 7/11 (395 mensajes en 31 chats de personas en unas 3 semanas):
    unos 19 al día entre enviados y recibidos. Por día: 2 revisiones con llamada perdida
    (0 y 2), abrir 2 chats en cada una (4 y 4), 10 respuestas (10 y 0), unas 6 tandas
    recibidas en conversación (0 y 6) y `g` y `gn` día por medio (1 y 1): 15 SMS al día del
    dueño y 13 de la puerta de enlace, unos 450 y 390 al mes. Abriendo 3 chats por
    revisión: 510 y 450. Uso intenso (el doble): 900 y 780. Tabla de `SMS_BRIDGE.md`
    actualizada.
  - Pérdida de mensajes (revisado, sin código): `messages` del motor marca como consultado
    todo lo que devuelve (`oc_chat.seen` pasa al `seq` más alto). Se pierde lo que no entra
    en la respuesta: en `n`, los más antiguos que no caben en 160; en `gn`, todo menos los
    3 últimos; en conversación, lo que pasa de 459; y en los tres, todo si el SMS no sale
    (descartado a los 10 minutos). Propuesta: `messages` devuelve el `seq` de cada mensaje
    y no marca nada; una orden nueva `seen` (chat y `seq`) marca hasta ese mensaje. El
    puente arma la respuesta del más antiguo al más nuevo y, cuando el SMS sale, manda
    `seen` con el último que entró. Lo que no cupo sigue en el `(k)` del menú (el motor ya
    cuenta los no leídos después de `seen`) y llega en el siguiente `n`, `gn` o tanda de
    conversación. Necesita recompilar e instalar el motor. Pendiente de decisión del dueño.
- Llamadas: 2 de 4 no llegaron al módem (sin `MSG_INCOMING_CALL_IND` en el registro
  de radio; el iPhone mostró "Llamada finalizada" enseguida). Pasó con y sin el
  puente: parece intermitente, de la red.
- El Fame se reinició solo a las 00:23 del 8 de noviembre (`reboot by NPON` en
  `/data/log/RR_NPON.p`), sin causa encontrada; el chip no tiene PIN.
- Textos del dueño puestos en `sms-bridge.sh` (11 de noviembre de 2026, etapa 2b parte 2,
  punto 5). Largo en septetos (los extendidos valen 2; el `^` del logo lo es): logo 26
  (2 líneas); bienvenida con logo 55 (máx. 60); ayuda 158 (máx. 160); pie 25 (máx. 25);
  `Enviado a` 9 (máx. 10) + nombre; `No se pudo enviar a` 19 (máx. 25) + nombre;
  `Nada nuevo` 10, con `: nombre` hasta 20 (máx. 25); sesión cerrada 43 (máx. 60); `Yo`
  2 (máx. 8); `Abre WhatsApp o la sesion se cierra` 35 (máx. 35).
  - Logo: siempre en la bienvenida y la ayuda. En las demás respuestas pedidas (menús,
    `00`, `n`, `gn`, no enviado, sesión cerrada) va arriba solo si cabe en el mismo SMS;
    el menú se arma sin él, así que nunca deja fuera un chat. No va en los reenvíos del
    modo conversación.
  - Ayuda: lleva arriba el aviso de 14 días y `Enviado a` (como el menú y `00`); si no
    cabe en 160, quita la última línea y después el logo.
  - Nombres: en el menú de personas, el nombre de pila de hasta 8 letras (como en los
    mensajes) y, si dos quedan iguales, la inicial del apellido (`Ana P`, `Ana M`); ese
    nombre corto va también en `Enviado a`, `No se pudo enviar a` y `Nada nuevo:`. Un chat
    sin nombre muestra el número entero. Grupos: los primeros 8 caracteres, sin espacios
    al final.
  - Probado con `-t -s`, SMS falsos (borrados) y el motor falso: bienvenida, ayuda
    completa, sin la última línea y sin logo, menú lleno sin logo, desempate, número,
    grupos, `gn`, `00`, no enviado y sesión cerrada. No se probó con nombres reales.
- Etapa 3, lo que no depende de la app (13 de noviembre de 2026, modo sin preguntas; los
  puntos 0 a 5 del pedido ya estaban hechos y con commit desde el 8 y el 11 de noviembre).
  - Registro del dueño (`54313b2`): sin número en la orden, el puente usa el registrado en
    `sms-bridge-owner` (junto al script). Si no hay, muestra `[CODIGO] NNNN` (4 dígitos al
    azar, 1000 a 9999) y la parte root (`--reg`) espera cada 2 s un SMS cuyo texto sea
    exactamente el código, llegado después de mostrarlo; el número que lo envía queda
    guardado y se borra su marcador de bienvenida, así su primer pedido la recibe. Al
    código no se responde (0 SMS de la puerta de enlace). Para cambiar de dueño se borra
    `sms-bridge-owner`. Marcador nuevo para el dueño: `T_COD` (`[CODIGO]`, máx. 40, texto de
    la pantalla de la puerta de enlace, va seguido del código).
  - Decisiones tomadas sin preguntar (todas se revierten con un commit):
    1. El número en la orden sigue aceptado y no se guarda: sirve para pruebas y no costó
       líneas.
    2. El número se guarda como lo entrega la red (en Chile llega con `+56`). Si llegara
       sin `+56`, `SmsSend` y `-s` usarían ese número sin prefijo; no se normaliza porque
       no se pudo ver un caso real sin SMS reales.
    3. El código no vence ni limita intentos: el registro solo está abierto mientras la
       pantalla muestra el código. Si el dueño quiere tope de intentos, es un cambio aparte.
    4. Esto cambia la sección 3 de `SMS_BRIDGE.md` (antes: el número nunca por SMS); el
       pedido de la etapa 3 lo define así y el documento quedó actualizado.
    5. `rm` de Android 4.1 no acepta `-f`: se usa `rm` con el error descartado.
  - Bienvenida: no necesitó código. El primer pedido respondido trae el logo de 2 filas y
    el mensaje de entrada arriba, en el mismo SMS (con un menú de 3 chats: 116 septetos).
    Sin cambiar desde el 11/11: si el primer pedido es `a`, la ayuda (158) ya trae el logo
    y el mensaje de entrada no se envía nunca, porque no cabe; y si el primer pedido es un
    texto que sale bien, la bienvenida va en la siguiente respuesta. Queda a decisión del
    dueño si el mensaje de entrada debe esperar a la siguiente respuesta después de `a`.
  - Revisión de palabras, orden y costo (sin cambios en `sms-bridge.sh`; los textos son del
    dueño). Igual que la terminal: etiquetas de adjuntos y `audio mm.ss` (salen del motor),
    mensajes del más antiguo al más nuevo, chats del más reciente al más antiguo, tecla
    primero y palabra después (como la guía), `Enviado a` / `No se pudo enviar a` (la guía
    dice `enviar`). Distinto de la terminal, para decisión del dueño: (1) `ayuda` en el SMS
    y `guía` en la terminal; (2) `Yo` en el SMS y `You` en la terminal (nchat sin traducir);
    (3) no leídos como `(k)` en el SMS y como marca y color en la terminal. Costo: toda
    respuesta pedida cabe en 1 SMS (menú, `n`, `gn`, ayuda, errores), el logo y la
    bienvenida solo van si caben en ese mismo SMS, no hay saltos de línea ni espacios al
    final, y nombres y textos pasan por el filtro GSM del motor. Único caso de más de 1
    SMS: una tanda del modo conversación (hasta 3 partes). Dato para decidir: en `n` y en
    conversación cada línea repite el nombre de la persona (hasta 10 septetos por línea);
    quitarlo en chats de personas ahorraría caracteres, pero cambia la sección 6 del diseño.
  - `SMS_BRIDGE.md` puesto al día con el código: registro por código (sección 3), etiquetas
    de adjuntos, texto del aviso de 14 días, textos de errores, logo si cabe. Del diseño
    siguen sin programar: `Sin internet desde HH:MM` con envío pendiente, `Quedan N SMS` y
    los pendientes de más de 10 minutos al abrir.
  - Probado en el Fame con `-t -s`, motor falso y SMS falsos del número `+56900000001`
    (borrados, `_id` > 87): un código equivocado de otro número se ignora; el código
    correcto registra; el primer pedido trae la bienvenida aunque el marcador existiera;
    al reiniciar sin número usa el registrado y no pide código; `0`, `a`, `1` y `g`
    responden igual que antes. Ningún SMS real y ningún envío por WhatsApp.
- En el Fame quedan `sms-bridge.sh` (versión del 13/11), `player.jar` y el marcador de bienvenida
  `sms-bridge-993359016`. `sms-test.sh`, `sms-test.log` y los registros del puente
  se borraron.

## Cierre del 7 de noviembre de 2026 (noche, después de las uniones)

- Ramas, todas sin subir y con el árbol limpio: `main` en `c83707f` (unión de
  `motor`, sin conflictos); `motor` en `30340c8` (no tiene `d127578` ni la unión,
  ya no se usa); `sms` en `1a5e3b0` (unión de `main`, conflicto solo en este
  archivo, resuelto juntando los dos textos). Rama actual: `sms`. `VERSION` es
  `0.2.4-dev`.
- `build.sh` pasó en `main` y en `sms` (sin errores en `build.log`); `engine/audio`
  no cambió. Lo último compilado es `sms`, igual a `main` en código.
- Fame: en `/data/local/tmp/oldiechat-engine/` están el motor (compilación de las
  23:03, con `pair_qr`), `glyphs.txt` y `data/` con la sesión vinculada de nuevo
  el 7/11 cerca de las 23:06 y el historial guardado. Motor detenido. Core 2 sin
  tocar. No se instaló nada en los teléfonos después de las uniones.
- Falta instalar en el Fame el motor de `out/engine/` y probar que vincula y
  conecta igual sin `pair_qr`.

## Cierre del 8 de noviembre de 2026 (madrugada)

- Rama actual `sms`, árbol limpio, sin subir: Área 5, etapa 2a hecha (commits
  `ef4042e` a `c871f21` y este cierre). `main` en `c83707f`, sin cambios hoy.
- Nada que compilar: la 2a no tocó el motor ni `player/`. El motor del Fame sigue
  siendo la compilación de las 23:03 del 7/11 (con `pair_qr`).
- Fame: sesión vinculada en `/data/local/tmp/oldiechat-engine/data`, motor y puente
  detenidos (confirmado con `ps`). Llamadas reales 48, 49 y 50 en el registro de
  llamadas; SMS falsos y llamada falsa borrados. Core 2 sin tocar.
- Falta que el dueño escriba los textos de los marcadores.

## Cierre del 8 de noviembre de 2026 (tarde)

- Rama actual `sms`, árbol limpio, sin subir: Área 5, etapa 2b parte 1 hecha (commits
  `2a31dca` a este cierre). `main` sigue en `c83707f`.
- Nada que compilar: `out/` tiene la compilación de las 19:07 del 8/11, igual al código
  de `sms` (el motor con `archived`).
- Fame: motor nuevo (19:07, sin `pair_qr`) en `/data/local/tmp/oldiechat-engine/`, con
  la sesión en `data/`; conecta. Respaldo del motor viejo borrado. Quedan
  `sms-bridge.sh` (versión de la parte 1) y el marcador `sms-bridge-993359016`. SMS
  falsos (`_id` > 87), ayudante, registros y `sms-bridge-sent` borrados. Motor y
  puente detenidos. Core 2 sin tocar.
- Falta: una prueba real de persona archivada, cuando
  el dueño archive una en el principal.
- Siguiente: Área 5, etapa 2b, parte 2.

## Cierre del 9 de noviembre de 2026

- `main` en `7aa7761`: solo `CLAUDE.md`, la entrada del Core 2 pasa a LineageOS 15.1
  Go (Android 8.1) como teléfono de prueba. Sin subir. `sms` no tiene ese commit;
  lo recibe cuando se una con `main`.
- Rama actual `sms`, sin cambios de código hoy. Nada que compilar ni probar.
- Core 2 sin tocar por Claude. Fame igual que en el cierre anterior.
- Siguiente: Área 5, etapa 2b, parte 2 (sin cambios).

## Cierre del 11 de noviembre de 2026

- Rama actual `sms`, árbol limpio, sin subir: Área 5, etapa 2b parte 2 hecha (commits
  `8928b77` a `32f526f` y este cierre). `main` sigue en `7aa7761`. Detalle en la
  sección Área 5.
- Hecho y probado sin SMS reales: modo conversación, `SmsSend` en partes con aviso de
  enviado y reintento, aviso de 14 días, textos del dueño con logo y nombres cortos,
  `00` quitado (responde el menú) y estimación mensual sin `00` (unos 450 SMS del dueño
  y 390 de la puerta de enlace al mes en uso normal).
- Sin compilar: `out/` no tiene el `player.jar` nuevo (`SmsSend`); el del Fame se compiló
  aparte con `player/build.sh`. El motor no cambió (`out/engine/` de las 19:07 del 8/11
  sigue al día). La próxima vez que corra `build.sh` en `sms`, el paquete de la terminal
  lleva el `player.jar` nuevo (el reproductor no cambió).
- Fame: en `/data/local/tmp/` están `sms-bridge.sh` (versión de `32f526f`), `player.jar`
  nuevo con su caché dex y el marcador `sms-bridge-993359016`. SMS falsos, registros,
  `sms-bridge-sent`, `sms-bridge-main` y `ft/` borrados. Modo avión apagado, pantalla
  sin "siempre encendida". Motor y puente detenidos. Core 2 sin tocar.
- Falta probar con saldo: envío real con `-s`, si el informe de entrega se cobra, falla
  real sin señal y `SmsSend` en Android 8.1.

## Cierre del 13 de noviembre de 2026

- Rama actual `sms`, árbol limpio, sin subir: Área 5, etapa 3, puntos 6 a 8 (registro del
  dueño, bienvenida y revisión de textos), solo en `sms-bridge.sh`. `main` sigue en `7aa7761`.
- Nada que compilar: no se tocó el motor ni `player/`.
- Fame: `sms-bridge.sh` del 13/11 en `/data/local/tmp/`, sin `sms-bridge-owner` (el dueño
  real no está registrado: el primer arranque sin número mostrará un código). SMS falsos y
  `ft/` borrados; motor y puente detenidos. Core 2 sin tocar.
- Falta: el texto de `T_COD`; las decisiones anotadas en la etapa 3 (Área 5); y, con saldo,
  un registro real (ver cómo entrega la red el número) además de lo pendiente del 11/11.

## Qué sigue

- Área 5, etapa 3: hecho lo que no depende de la app (puntos 6 a 8); el resto de la etapa
  espera a la app.
- Área 5, etapa 2b: partes 1 y 2 hechas. Decisión pendiente del dueño: la propuesta para
  que no se pierdan los mensajes que no caben (orden `seen` en el motor; sección Área 5),
  y si `gn` entrega lo pendiente de a poco o sigue con los 3 últimos. Se trabaja en
  `sms`, que ya tiene `main` y `motor`.
- Área 1, etapa 7: probar cuando aparezcan el cambio de nombre de grupo y las
  etiquetas `ubicacion` y `contacto`.
- Decidir cuándo la rama `sms` se une a `main` y qué parte de la prueba se conserva.
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
| `scripts/` | `phone-test.sh`, `glyphs.sh`/`glyphs.py`, `make-emoji-font.sh`, `make-icon.sh`, `check-go-version.sh`, `update-whatsmeow.sh`, `vendor-go.sh`, `sms-bridge.sh` |
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
