# Arquitectura de la app OldieChat (propuesta)

Estado: **propuesta para revisión**. La interfaz no se ha empezado; el motor
(`engine/`) ya existe y es el mismo que usará la app.

## 1. Objetivos

- App Android **minimalista**: lista de chats, conversación, vinculación y nada más.
- Funciona desde **Android 4.1 (API 16)** hasta las versiones actuales.
- **Sin root**: todo vive en el almacenamiento privado de la app.
- Comparte el motor con OldieChat terminal, para que una corrección sirva a los dos.
- Sin la marca WhatsApp en el nombre, el ícono ni los colores. La descripción dice
  "compatible con WhatsApp" y advierte que es un cliente no oficial.

## 2. Componentes

```
┌──────────────────────────── APK ────────────────────────────┐
│                                                             │
│  Interfaz (Java)            EngineService (Java)            │
│  ─ ChatsActivity  ◄──────►  servicio en primer plano        │
│  ─ ChatActivity    eventos  ─ lanza y vigila el motor       │
│  ─ PairActivity             ─ notificaciones                │
│                             ─ reproduce audio (MediaPlayer) │
│                                   │ stdin/stdout JSON       │
│                                   ▼                         │
│      lib/<abi>/liboldiechat_engine.so  (ejecutable Go)      │
│      ─ whatsmeow (sesión, mensajes)                         │
│      ─ Opus → WAV       ─ DNS y certificados propios        │
│      ─ zona horaria     ─ session.db en filesDir            │
└─────────────────────────────────────────────────────────────┘
```

- **Interfaz (Java, APIs del framework)**: sin AndroidX ni bibliotecas de
  terceros, porque cada vez más bibliotecas dejan de soportar API 16 a 20. Vistas
  simples (`ListView`, `EditText`), tema oscuro y letra grande.
- **EngineService**: un `Service` que lanza el motor como proceso hijo, traduce
  sus eventos para la interfaz y muestra las notificaciones.
- **Motor** (`engine/cmd/oldiechat-engine`): un ejecutable Go con
  whatsmeow, el mismo código que se prueba hoy desde la terminal.

## 3. El motor como ejecutable dentro del APK

**Por qué un proceso aparte y no una biblioteca JNI (gomobile)**:

- Si el motor falla, la interfaz sigue viva y lo relanza.
- Es el mismo binario que se prueba por ADB o en OldieChat terminal
  (`oldiechat-engine selftest`, `run`).
- gomobile exige API 21 o más nueva y mete el runtime de Go dentro del proceso de
  la interfaz.

**Compilación**

- Ejecutables **PIE estáticos con musl** (`-buildmode=pie`, enlace externo con
  `-static-pie`), sin depender de Bionic ni del enlazador de Android:
  - `armeabi-v7a`: contenedor Alpine armv7, igual que hoy.
  - `arm64-v8a`: contenedor Alpine aarch64 con el Go oficial `linux-arm64` y el
    mismo parche de musl.
- PIE es obligatorio desde Android 5 y Android 4.1 ya lo admite, así que un mismo
  binario por arquitectura sirve para todas las versiones.
- cgo sigue activo por libopus y go-sqlite3, compilados estáticos como hoy.

**Ubicación en el APK**

- Desde Android 10, una app no puede ejecutar archivos de sus carpetas de datos
  (W^X); sí puede ejecutar los de su **carpeta de librerías nativas**.
- Por eso el motor va en `lib/<abi>/liboldiechat_engine.so` (el nombre debe
  empezar con `lib` y terminar en `.so` para que el instalador lo copie), con
  `android:extractNativeLibs="true"` para que quede como archivo real en
  `nativeLibraryDir`.
- Se lanza con
  `new ProcessBuilder(getApplicationInfo().nativeLibraryDir + "/liboldiechat_engine.so", "run", ...)`.
  Funciona igual en Android 4.1, que no tiene esa restricción.

## 4. Comunicación interfaz ↔ motor

Líneas JSON por stdin/stdout (una línea = un mensaje). Los registros del motor
van por stderr y el servicio los pasa a logcat.

Arranque:

```
liboldiechat_engine.so run --data <filesDir>/engine \
    --certs <filesDir>/cacert.pem --tz America/Santiago --dns 1.1.1.1:53,8.8.8.8:53
```

Comandos (interfaz → motor), ya implementados en el prototipo:

| Comando | Respuesta |
| --- | --- |
| `{"cmd":"pair","phone":"56912345678"}` | `{"type":"pair_code","text":"ABCD-EFGH"}` |
| `{"cmd":"send","chat":"<jid>","text":"hola"}` | `{"type":"sent","chat":"<jid>","id":"..."}` |
| `{"cmd":"quit"}` | el motor termina |

Eventos (motor → interfaz):

| Evento | Campos |
| --- | --- |
| `need_pairing` | la sesión no está vinculada |
| `paired` | `sender` (la cuenta vinculada) |
| `connected` / `disconnected` / `logged_out` | — |
| `message` | `chat`, `sender`, `name`, `id`, `time`, `from_me`, `text` o `audio` + `seconds` |
| `audio_ready` | `chat`, `id`, `path` (WAV listo para `MediaPlayer`) |
| `error` | `error`, y `chat`/`id` si corresponde |

Pendiente para la primera versión de la app: lista de chats con nombres y
archivados (`chats`), historial (`history`), marcar como leído (`read`),
`archive`, y un evento `hello` con la versión del protocolo para que la interfaz
detecte un motor incompatible.

## 5. Red, certificados y hora sin root

- **DNS**: el resolvedor de Go, sin `/etc/resolv.conf`, consulta `localhost:53` y
  falla. `engine/netcfg` lo apunta a servidores públicos o a los que pase la
  interfaz. En Android 5+ se pueden leer los DNS de la red actual con
  `ConnectivityManager.getLinkProperties().getDnsServers()` y pasarlos con
  `--dns`.
- **Certificados**: los de Android 4.x están vencidos o incompletos. El APK trae
  `cacert.pem` (paquete de Mozilla), que se copia a `filesDir` y se pasa con
  `--certs`. Se actualiza con cada versión de la app.
- **Zona horaria**: la interfaz pasa `TimeZone.getDefault().getID()` con `--tz`;
  los datos de zonas van dentro del motor (`time/tzdata`).

## 6. Servicio en primer plano y notificaciones

- **EngineService** mantiene el motor vivo con una notificación fija ("OldieChat
  conectado"):
  - Android 4.1–7: `startForeground(id, notification)`.
  - Android 8+: `startForegroundService()` y un canal de notificaciones.
  - Android 14+: `android:foregroundServiceType="remoteMessaging"` con su permiso
    `FOREGROUND_SERVICE_REMOTE_MESSAGING`.
- **Mensajes nuevos**: una notificación por chat, solo con el nombre y el texto.
- **Permiso de notificaciones**: en Android 13+ se pide `POST_NOTIFICATIONS` al
  terminar la vinculación, explicando para qué sirve.
- **Batería**: en Android 6+ se ofrece (sin obligar) excluir la app de la
  optimización de batería, porque si no Doze corta la conexión.

## 7. Vinculación con código numérico

En pantallas de 3,5" un código QR es difícil de escanear, y la app corre en el
mismo teléfono que se quiere vincular.

1. La persona escribe su número con código de país.
2. El motor pide el código (`PairPhone`) y la app muestra `ABCD-EFGH` en grande.
3. En el teléfono principal: Dispositivos vinculados → Vincular con número de
   teléfono → ingresar el código.
4. Llega `paired` y luego `connected`.

## 8. Audio

- **Recibir**: el motor descarga la nota de voz, la convierte a WAV
  (`engine/audio/oggopus`) y avisa con `audio_ready`. La interfaz la reproduce con
  `MediaPlayer`, igual que `player.jar` hoy.
- **Enviar** (más adelante): `AudioRecord` en PCM, codificado a Opus en el motor
  con el codificador de libopus.

## 9. Datos y seguridad

- Todo en el almacenamiento privado: `filesDir/engine/session.db` (claves de la
  sesión) y `filesDir/engine/media/`.
- `android:allowBackup="false"`, para que las claves no salgan en copias de
  seguridad.
- El motor corre con el usuario de la app, sin root.

## 10. Compilación de la app

- **Sin Gradle**: un script como `player/build.sh` con `aapt2`, `d8` y
  `apksigner` en versiones fijas en `versions.env`. Así se evita depender de
  versiones del Android Gradle Plugin que van subiendo el mínimo de Android
  soportado, y se puede reconstruir dentro de unos años.
- `minSdkVersion 16` y `targetSdkVersion` actual. El motor se compila con
  `build.sh` y se copia a `lib/<abi>/`.

## 11. Interfaz mínima

- **Chats**: lista (archivados al final, en una sección plegada), toque para
  abrir.
- **Chat**: mensajes y campo de texto. Tocar una nota de voz la reproduce;
  tocarla otra vez la detiene.
- **Vincular**: número de teléfono y código.
- **Ajustes**: tamaño de letra y cerrar sesión.

## 12. Preguntas para revisar

1. ¿La lista de archivados al final en una sección plegada, o una pantalla aparte?
2. ¿Notificaciones con el texto del mensaje, o solo "Mensaje de <nombre>"?
3. ¿Distribución solo por GitHub Releases, o también F-Droid? (F-Droid marcaría
   el antirrasgo "servicio de red no libre").
4. ¿ARM64 desde la primera versión o primero solo ARMv7?
