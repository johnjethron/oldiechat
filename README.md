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
- Mostrar los emoji que la fuente de Android 4.x puede dibujar y reemplazar el
  resto por emoticonos cortos.

Por ahora no envía audios, imágenes ni archivos, ni muestra imágenes.

Probado en un **Samsung Galaxy Fame GT-S6810L** (Android 4.1.2, kernel 3.0.101,
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
   - instala la configuración (`key.conf`, `ui.conf`, `glyphs.txt`) y respalda
     la que ya existía como `.bak`;
   - crea `/system/etc/resolv.conf` con DNS públicos (`1.1.1.1` y `8.8.8.8`);
   - instala certificados raíz actuales en
     `/system/etc/ssl/certs/ca-certificates.crt`;
   - guarda una copia `.orig` de esos dos archivos si ya existían;
   - crea el comando `/system/bin/wsp`;
   - copia el ícono a `/sdcard/OldieChat/oldiechat.png`.

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

Después cierra TermOne Plus del todo y vuelve a abrirlo.

Para abrir OldieChat escribe `wsp` en TermOne Plus.

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

Volumen arriba = **Fn**, Volumen abajo = **Ctrl**. Un modificador se aprieta y se
suelta antes de la tecla; apretado dos veces queda fijo hasta volver a apretarlo.

| Teclas | Acción |
| --- | --- |
| Enter | enviar mensaje |
| Fn+0 | salto de línea |
| Fn+1 / Fn+2 | conversación anterior / siguiente |
| Fn+3 | siguiente conversación no leída |
| Fn+4 | buscar conversación por nombre |
| Fn+5 | mostrar u ocultar la lista |
| Fn+6 | insertar emoji |
| Fn+7 | reaccionar al mensaje seleccionado |
| Fn+8 | ayuda en pantalla |
| Fn+9 | alternar entre chats normales y **archivados** |
| Fn+W / Fn+S | subir / bajar de a un mensaje (selecciona el mensaje) |
| Fn+P / Fn+N | subir / bajar una página |
| Ctrl+9 | reproducir el audio seleccionado (otra vez: detener) |
| Ctrl+0 | detener el audio |
| Ctrl+Q | salir |

El resto de los atajos de nchat siguen disponibles con Ctrl (ver
[nchat](https://github.com/d99kris/nchat#usage)).

**Toques**: tocar un nombre de la lista abre esa conversación. Dos toques
seguidos (en menos de 3 segundos) en el área de escritura abren o cierran el
teclado. El botón Atrás también cierra el teclado.

**Archivados**: Fn+9 cambia la lista para mostrar solo los chats archivados y la
barra de estado muestra `[Archivados]`. Fn+9 otra vez vuelve a la lista normal.

**Audios**: selecciona el mensaje de voz con Fn+W/Fn+S y aprieta Ctrl+9. El audio
se descarga, se convierte y suena en segundo plano después de 1 o 2 segundos.
Ctrl+0 lo detiene; también se detiene al salir.

## Si después usas `adb shell` sin root

`wsp` ejecuta OldieChat como root, así que los archivos nuevos quedan a nombre de
root. Para volver a usarlo desde `adb shell` sin root:

```
su -c "chown -R shell:shell /data/local/tmp/oldiechat/home"
```

## Limitaciones conocidas

- **Emoji**: la fuente de Android 4.1 solo trae emoji de 2012 y en blanco y negro.
  Los posteriores se muestran como `[e]` o como un emoticono corto. Las caras se
  muestran siempre como emoticono (`:)`, `XD`, `<3`), porque en esa fuente son
  dibujos del robot de Android. Los mensajes se envían con los emoji originales.
- **Desplazamiento con los botones de volumen**: en TermOne Plus un botón de
  volumen configurado como modificador no puede además enviar una tecla propia;
  por eso se desplaza con Fn+W/S y Fn+P/N.
- **Teclado**: con "Enviar eventos de ratón" activado, TermOne Plus no abre el
  teclado con un toque simple; OldieChat lo resuelve con el doble toque en el
  área de escritura.
- Sin portapapeles del sistema, sin envío de audios, imágenes ni archivos, y sin
  vista de imágenes.
- Go 1.26 pide oficialmente un kernel Linux 3.2 o más nuevo; en el kernel 3.0.101
  del Galaxy Fame funciona.
- Solo se ha probado en un Galaxy Fame. Otros Android 4.x ARMv7 con root
  deberían funcionar; para que los emoji se vean bien en otro modelo, genera
  `glyphs.txt` con sus fuentes (ver más abajo).

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

Para generar `config/glyphs.txt` con las fuentes de otro teléfono conectado:

```bash
tools/glyphs.sh
```

### Cómo funciona

- **nchat** se compila con WhatsApp activo y Telegram y Signal desactivados,
  dentro de un contenedor Alpine armv7 (musl), con Go parcheado (Go PR #69325,
  necesario para la parte de whatsmeow en musl) y enlazado con
  `-static -no-pie`.
- **oldiechat-audio** (`audio/`, Go + libopus) convierte notas de voz Ogg Opus a
  WAV. El paquete `oggopus` está pensado para reutilizarse en el motor de la
  futura app.
- **player.jar** (`player/`, Java) reproduce con el `MediaPlayer` de Android,
  lanzado con `app_process`, sin instalar ninguna app.
- **oldiechat.sh** prepara el entorno: terminfo, zona horaria (Android usa un
  formato de tzdata propio), `HOME` y carpeta temporal.

Parches aplicados a nchat (`patches/`):

| Parche | Qué hace |
| --- | --- |
| 0001 | Tiempos de espera más largos al vincular y conectar (CPU lenta). |
| 0002 | Elegir chat tocando la lista; dos toques en el área de escritura para el teclado. |
| 0003 | Los chats archivados no reaparecen al cambiar su identificador (LID ↔ número). |
| 0004 | Filtro de glifos (`glyphs.txt`) para fuentes antiguas y anchos de carácter distintos. |
| 0005 | Usar `/system/bin/sh` en Android para ejecutar comandos externos. |
| 0006 | Vista de chats archivados (`toggle_archived`). |
| 0007 | Tecla `stop` y opción `attachment_stop_command`. |

### Estructura

```
build.sh            compilación completa
Dockerfile.armv7    imagen Alpine armv7
patches/            parches a nchat
audio/              conversor Opus -> WAV (Go)
player/             reproductor (Java, app_process)
files/              scripts e ícono que van en el paquete
config/             key.conf, ui.conf, glyphs.txt
tools/              generador de glyphs.txt e ícono
```

## Licencias

- El código propio de OldieChat terminal (scripts, parches, `audio/`, `player/`,
  herramientas) se distribuye bajo la licencia [MIT](LICENSE).
- [nchat](https://github.com/d99kris/nchat) se distribuye bajo la licencia MIT.
- [whatsmeow](https://github.com/tulir/whatsmeow) se distribuye bajo la Mozilla
  Public License 2.0, sin modificaciones (incluido en el código de nchat).
- El **binario combinado** del paquete se distribuye bajo la **GNU GPL v3**,
  igual que los binarios de nchat sin Signal. Las licencias completas de nchat,
  whatsmeow, libopus y las librerías estáticas van en `licenses/` dentro del
  paquete. El código fuente correspondiente es este repositorio más el commit de
  nchat indicado en `build.sh`.

## Créditos

- [nchat](https://github.com/d99kris/nchat), de Kristofer Berggren.
- [whatsmeow](https://github.com/tulir/whatsmeow), de Tulir Asokan.
- [TermOne Plus](https://gitlab.com/termapps/termoneplus), continuación de
  Terminal Emulator for Android.
- [Opus](https://opus-codec.org/), de Xiph.Org.
