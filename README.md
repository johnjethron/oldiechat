# OldieChat terminal

**Español** · [English](README.en.md)

Cliente de mensajería de terminal **compatible con WhatsApp** para teléfonos
Android antiguos (Android 4.x, ARMv7, con root). Es la primera etapa del
proyecto OldieChat; más adelante vendrá una app Android en Java.

Está basado en [nchat](https://github.com/d99kris/nchat) y
[whatsmeow](https://github.com/tulir/whatsmeow), compilados como un binario
estático que no depende de las librerías de Android.

> [!WARNING]
> **Cliente no oficial.** OldieChat no está afiliado, asociado ni respaldado por
> WhatsApp ni por Meta. Usar clientes no oficiales va en contra de los términos de
> servicio de WhatsApp, y **WhatsApp puede suspender o bloquear tu cuenta**. Úsalo
> bajo tu propio riesgo. "WhatsApp" es una marca de WhatsApp LLC y aquí solo se
> nombra para indicar compatibilidad.

## Motivación

Hice OldieChat para la gente que quiere revivir sus teléfonos antiguos y darles
una segunda vida, en vez de dejarlos en un cajón.

También es mi forma de luchar contra el doomscrolling: un teléfono simple, que
solo tenga lo esencial para hablar con las personas que me importan, sin feeds
infinitos ni notificaciones que compiten por mi atención.

Y quiero contar algo: yo nunca imaginé que estaría metido en el mundo del
desarrollo. Hoy existen herramientas que permiten que cualquier persona con
pasión y ganas pueda crear cosas como esta. Yo lo logré, y tú también puedes.

## Qué hace

- Enviar y recibir mensajes de texto, con la interfaz de nchat adaptada a una
  pantalla de 3,5" y al teclado táctil.
- Elegir una conversación tocando su nombre en la lista.
- Abrir el teclado con dos toques en el área de escritura.
- Mostrar u ocultar los chats archivados con un atajo.
- Escuchar notas de voz en segundo plano: se convierten de Opus a WAV y suenan
  con el reproductor de Android.
- Mostrar la hora de la zona horaria del teléfono.
- Mostrar emoji en blanco y negro con la fuente Noto Emoji, y reemplazar por un
  emoticono corto los pocos que no se pueden dibujar bien.

Por ahora no envía audios, imágenes ni archivos, ni muestra imágenes.

Probado en un **Samsung Galaxy Fame GT-S6810L** (Android 4.1.2, kernel 3.0.15,
Cortex-A9, 512 MB de RAM, root con SuperSU).

## Requisitos

**Teléfono**

- Android 4.x con procesador ARMv7 y **root**.
- Depuración USB activada.
- [TermOne Plus](https://f-droid.org/packages/com.termoneplus/) (F-Droid), una
  terminal mantenida compatible con Android 4.1.
- Opcional: Nova Launcher u otro launcher que permita accesos directos con ícono
  propio.

**Equipo** (para instalar): Linux con `adb`. Para compilar también se necesitan
Docker, `qemu-user-static` y `binfmt-support`.

## Instalación rápida (desde Releases)

1. Descarga `oldiechat-terminal-<versión>-armv7.tar.gz` y su `.sha256` de la
   sección Releases.
2. Comprueba y descomprime:

   ```bash
   sha256sum -c oldiechat-terminal-0.1.0-armv7.tar.gz.sha256
   ```

   ```bash
   tar xzf oldiechat-terminal-0.1.0-armv7.tar.gz
   ```

3. Conecta el teléfono por USB, desbloquéalo y ejecuta:

   ```bash
   cd oldiechat-terminal-0.1.0-armv7 && ./install.sh
   ```

   Acepta el permiso de SuperSU si aparece. El script:

   - copia el programa a `/data/local/tmp/oldiechat`;
   - instala la configuración (`key.conf`, `ui.conf`, `color.conf`,
     `glyphs.txt`, `guide.txt`) y respalda la que ya existía como `.bak`;
   - crea `/system/etc/resolv.conf` con DNS públicos (`1.1.1.1` y `8.8.8.8`);
   - instala certificados raíz actuales en
     `/system/etc/ssl/certs/ca-certificates.crt`;
   - guarda una copia `.orig` de esos dos archivos si ya existían;
   - crea el comando `/system/bin/wsp`;
   - copia el ícono a `/sdcard/OldieChat/oldiechat.png`;
   - instala la fuente de emoji en `/system/fonts/NotoEmoji-OldieChat.ttf` y la
     agrega a `/system/etc/fallback_fonts*.xml`, guardando el original como
     `.orig`. La primera vez pide **reiniciar el teléfono** (ver
     [Fuente de emoji](#fuente-de-emoji)).

   Si ya tenías una instalación anterior en `/data/local/tmp/nchat`, mueve la
   sesión a la ruta nueva y no hay que volver a vincular.

   Variables opcionales: `NAMESERVERS="9.9.9.9"`,
   `CA_BUNDLE=/ruta/certificados.pem` y `ANDROID_SERIAL=...` si hay más de un
   teléfono conectado.

4. Vincula tu cuenta (solo la primera vez). Usa una ventana de terminal grande en
   el equipo para que quepa el código QR:

   ```bash
   adb shell
   ```

   ```
   su -c "TERM=screen-256color /data/local/tmp/oldiechat/oldiechat.sh --setup"
   ```

   Elige WhatsApp y escanea el QR desde el teléfono principal, en
   **Dispositivos vinculados**. Después del escaneo puede tardar un par de
   minutos sin mostrar nada; hay que esperar.

## Configurar TermOne Plus

En **Preferencias**:

| Opción | Valor |
| --- | --- |
| Tipo de terminal | `screen-256color` (necesario para los toques) |
| Enviar eventos de ratón | activado |
| Tecla Ctrl | Volumen abajo |
| Tecla FN | Volumen arriba |
| Tamaño de fuente | el que te resulte legible (10–12 en 3,5") |
| Cerrar ventana al salir | activado |
| Acción del botón ATRÁS | Envía TAB al terminal (Atrás = volver) |

Después cierra TermOne Plus del todo y vuelve a abrirlo.

Para abrir OldieChat escribe `wsp` en TermOne Plus. La primera vez aparece
SuperSU: da permiso marcando "Recordar". Si falla, borra TermOne Plus en SuperSU
y vuelve a intentarlo.

## Acceso directo con ícono (Nova Launcher)

TermOne Plus trae un acceso directo que ejecuta un comando, así la terminal sigue
abriéndose normal y OldieChat tiene su propio ícono.

1. Mantén apretado un espacio vacío de la pantalla de inicio y elige
   **Widgets**.
2. Busca **Acceso directo a terminal** (TermOne Plus) y arrástralo a la pantalla.
3. En la ventana que se abre:
   - **Comando**: `/system/bin/wsp`
   - **Argumentos**: vacío
   - **Etiqueta acceso directo**: `OldieChat`
4. Para el ícono: mantén apretado el acceso directo, elige **Editar**, toca el
   ícono y selecciona `/sdcard/OldieChat/oldiechat.png` desde la galería o el
   explorador de archivos.

## Atajos

Una sola regla: **Volumen arriba = moverse**, **Volumen abajo = acción**. El
botón de volumen se aprieta y se suelta antes de la letra; apretado dos veces
queda fijo y otra vez lo suelta (los dos botones funcionan igual). La misma tabla
aparece en el teléfono con Volumen abajo + G.

| Teclas | Qué hace |
| --- | --- |
| Vol. arriba + W | subir en la conversación (selecciona mensajes) |
| Vol. arriba + S | bajar en la conversación |
| Vol. arriba + A | chat anterior |
| Vol. arriba + D | chat siguiente |
| Enter | enviar mensaje |
| Enter sobre un audio | escuchar; otra vez: detener |
| Vol. abajo + A | **A**rchivados (mostrar u ocultar) |
| Vol. abajo + G | **G**uía (esta tabla) |
| Vol. abajo + S | volver (o **S**alir) |
| Atrás | igual que Vol. abajo + S (con TermOne Plus configurado como se indica arriba) |

- **Volver**, paso a paso: si estás revisando mensajes, vuelve a la lista de
  chats; si estás en los archivados, vuelve a la lista normal; si estás en la
  guía, la cierra. Solo desde la lista principal sale de OldieChat, y pide
  confirmar con Vol. abajo + S otra vez.
- A y D cambian de chat siempre, también con un mensaje a medio escribir: el
  texto queda guardado como borrador en ese chat y aparece al volver.
- Enter envía siempre que haya texto escrito. Solo con el campo de escritura
  vacío, Enter sobre un audio seleccionado lo escucha o lo detiene, y sobre otro
  mensaje te devuelve a escribir.
- **El cursor está siempre al final del texto**: para corregir, borra. Ninguna
  tecla lo mueve hacia atrás.
- Todos los demás atajos de nchat están desactivados.
- **Audios**: se muestran como `audio 00.33` (minutos.segundos). Se descargan, se
  convierten y suenan en segundo plano después de 1 o 2 segundos, y se detienen
  al salir. Si uno no suena, el detalle de cada paso queda en
  `/data/local/tmp/oldiechat/home/audio.log`.
- **Archivados**: la barra de estado muestra `[Archivados]` mientras ves esa
  lista, que incluye todos tus chats archivados.
- **Toques**: tocar un nombre de la lista abre esa conversación, y dos toques
  seguidos en el área de escritura abren o cierran el teclado.

## Si después usas `adb shell` sin root

`wsp` ejecuta OldieChat como root, así que los archivos nuevos quedan a nombre de
root. Para volver a usarlo desde `adb shell` sin root:

```
su -c "chown -R shell:shell /data/local/tmp/oldiechat/home"
```

## Limitaciones conocidas

- **Emoji**: se ven en blanco y negro (Noto Emoji). Los que la fuente no tiene, o
  que se dibujan más anchos que su espacio en la terminal (algunos símbolos como
  ☀ o ❤), se muestran como un emoticono corto (`<3`, `(sol)`) o como `[e]`. Los
  mensajes se envían con los emoji originales.
- **Texto en otros alfabetos** (chino, japonés, coreano): las fuentes de Android
  4.1 los dibujan con otro ancho que la terminal, así que se muestran como `?`.
- **Desplazamiento con los botones de volumen**: en TermOne Plus un botón de
  volumen configurado como modificador no puede además enviar una tecla propia;
  por eso se desplaza con Volumen arriba + W/S.
- **Teclado**: con "Enviar eventos de ratón" activado, TermOne Plus no abre el
  teclado con un toque simple; OldieChat lo resuelve con el doble toque en el
  área de escritura.
- Sin portapapeles del sistema, sin envío de audios, imágenes ni archivos, y sin
  vista de imágenes.
- Go 1.26 pide oficialmente un kernel Linux 3.2 o más nuevo; en el kernel 3.0.15
  del Galaxy Fame funciona.
- Solo se ha probado en un Galaxy Fame. Otros Android 4.x ARMv7 con root
  deberían funcionar; para que los emoji se vean bien en otro modelo, vuelve a
  medir con `scripts/glyphs.sh` (ver más abajo).

## Fuente de emoji

`install.sh` instala Noto Emoji (versión monocroma de Google, licencia SIL OFL
1.1, 850 KB) en `/system/fonts` y la pone en la lista de respaldo de Android
antes de `AndroidEmoji.ttf`, la fuente original que dibuja las caras como
robots. Android solo lee esa lista al arrancar, así que hay que reiniciar una vez.

Para volver atrás, desde el equipo:

```bash
adb shell
```

```
su
mount -o remount,rw /system
for f in /system/etc/fallback_fonts*.xml.orig; do cat $f > ${f%.orig}; rm $f; done
rm /system/fonts/NotoEmoji-OldieChat.ttf
mount -o remount,ro /system
reboot
```

Después del reinicio, vuelve a medir con `scripts/glyphs.sh` y ejecuta de nuevo
`install.sh` para que `glyphs.txt` corresponda a las fuentes del teléfono.

## Compatibilidad

OldieChat existe para que los teléfonos antiguos sigan funcionando, así que todo
lo necesario para compilarlo queda fijado y guardado:

- Versiones exactas de Alpine, Go, nchat, whatsmeow, libopus y del compilador
  Java en un solo archivo, [`versions.env`](versions.env), con sus checksums.
- Las dependencias Go guardadas en el repositorio (`nchat/vendor/`,
  `engine/vendor/`) y los parches en `nchat/patches/` (y `go/patches/` para Go).
- Cada versión publica también un paquete con el código fuente completo.
- `scripts/check-go-version.sh` avisa si whatsmeow o nchat empiezan a exigir un
  Go más nuevo, y `scripts/phone-test.sh` prueba el teléfono (arranque, DNS,
  HTTPS, audio) antes de cada versión.

Qué hacer si Go deja de funcionar en un kernel antiguo, si whatsmeow exige un Go
más nuevo o si vencen los certificados: [MAINTAINING.md](MAINTAINING.md).

## Compilar desde el código

```bash
sudo apt install -y docker.io qemu-user-static binfmt-support adb curl
```

```bash
sudo usermod -aG docker $USER
```

Cierra sesión y vuelve a entrar. Luego:

```bash
./build.sh
```

La compilación corre emulada (Alpine armv7 sobre qemu) y tarda bastante. El
resultado queda en `out/oldiechat-terminal-<versión>-armv7/` y en el `.tar.gz`
con su `.sha256` para Releases. `./build.sh shell` abre una shell en el
contenedor.

Para generar `phone/config/glyphs.txt` midiendo el teléfono conectado (unos 9
minutos): el programa `GlyphProbe` pregunta a Android el ancho de cada carácter
y lo dibuja, igual que TermOne Plus.

```bash
scripts/glyphs.sh
```

### Cómo funciona

- **nchat** se compila con WhatsApp activo y Telegram y Signal desactivados,
  dentro de un contenedor Alpine armv7 (musl), con Go parcheado (Go PR #69325,
  necesario para la parte de whatsmeow en musl) y enlazado con
  `-static -no-pie`.
- **El motor** (`engine/`, Go) es independiente de nchat y es la base de la
  futura app Android: conversión Opus→WAV (`oldiechat-audio`, que usa este
  paquete), DNS y certificados sin root, zona horaria y un núcleo de mensajería
  sobre whatsmeow (`oldiechat-engine`). Ver
  [docs/APP_ARCHITECTURE.md](docs/APP_ARCHITECTURE.md).
- **player.jar** (`player/`, Java) reproduce con el `MediaPlayer` de Android,
  lanzado con `app_process`, sin instalar ninguna app.
- **oldiechat.sh** prepara el entorno: terminfo, zona horaria (Android usa un
  formato de tzdata propio), `HOME` y carpeta temporal.

Parches aplicados a nchat (`nchat/patches/`):

| Parche | Qué hace |
| --- | --- |
| 0001 | Tiempos de espera más largos al vincular y conectar (CPU lenta). |
| 0002 | Elegir chat tocando la lista; dos toques en el área de escritura para el teclado. |
| 0003 | Los chats archivados no reaparecen al cambiar su identificador (LID ↔ número). |
| 0004 | Filtro de glifos (`glyphs.txt`) para fuentes antiguas y anchos de carácter distintos. |
| 0005 | Usar `/system/bin/sh` en Android para ejecutar comandos externos. |
| 0006 | Vista de chats archivados (`toggle_archived`). |
| 0007 | Registrar en el log cada intento de abrir un adjunto y el comando lanzado. |
| 0008 | Listar todos los chats archivados guardados, aunque no tengan mensajes recientes. |
| 0009 | Atajos simples, volver, guía (`guide.txt`) y cursor siempre al final. |
| 0010 | Adjuntos con etiqueta corta: `audio mm.ss`, `imagen`, `video`, `sticker`, `documento pdf`. |
| 0011 | Anchos de carácter de la terminal (medidos en el teléfono) en lugar de los de la biblioteca C. |
| 0012 | Versión de whatsmeow (fecha, `go.mod`, licencias); la genera `scripts/update-whatsmeow.sh`. |

Los parches al runtime de Go, si alguna vez hacen falta, van en `go/patches/`
(ver [MAINTAINING.md](MAINTAINING.md)).

### Estructura

```
build.sh            compilación completa
Dockerfile.armv7    imagen Alpine armv7
versions.env        versiones exactas y checksums
nchat/patches/      parches a nchat
nchat/vendor/       dependencias Go de nchat (go mod vendor)
go/patches/         parches propios al runtime de Go (vacío por ahora)
engine/             motor Go: audio, red, zona horaria, mensajería
player/             Java: reproductor y medición de glifos (app_process)
phone/              lo que se instala en el teléfono: scripts, ícono,
                    config/ (key, ui, color, glyphs, guide), fonts/ y
                    licenses/ (licencias que no trae la compilación)
scripts/            pruebas, glifos, fuente de emoji, ícono, versión de Go, vendor
tests/data/         audio de prueba
docs/               estado del proyecto y arquitectura de la futura app
```

## Licencias

- El código propio de OldieChat terminal (scripts, parches, `engine/`, `player/`)
  se distribuye bajo la licencia [MIT](LICENSE).
- [nchat](https://github.com/d99kris/nchat) se distribuye bajo la licencia MIT.
- [whatsmeow](https://github.com/tulir/whatsmeow) se distribuye bajo la Mozilla
  Public License 2.0, sin modificaciones (incluido en el código de nchat).
- La fuente [Noto Emoji](https://github.com/googlefonts/noto-emoji) se distribuye
  bajo la SIL Open Font License 1.1 (`licenses/OFL.txt` en el paquete).
- El **binario combinado** del paquete se distribuye bajo la **GNU GPL v3**,
  igual que los binarios de nchat sin Signal.
- `licenses/` dentro del paquete trae las licencias completas de todo lo que va
  en él: OldieChat, nchat, whatsmeow y sus dependencias Go, libopus, Go, musl, el
  runtime de GCC (con su excepción), las librerías estáticas (OpenSSL, zlib,
  ncurses, SQLite, libmagic y sus compresores) y Noto Emoji. Los datos de zonas
  horarias (tzdata) son de dominio público.
- El código fuente correspondiente es este repositorio más el commit de nchat
  indicado en `versions.env`, y se publica completo en cada versión.

## Créditos

- [nchat](https://github.com/d99kris/nchat), de Kristofer Berggren.
- [whatsmeow](https://github.com/tulir/whatsmeow), de Tulir Asokan.
- [TermOne Plus](https://gitlab.com/termapps/termoneplus), continuación de
  Terminal Emulator for Android.
- [Opus](https://opus-codec.org/), de Xiph.Org.
