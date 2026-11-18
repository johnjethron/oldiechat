OLDIECHAT - PENDIENTES PARA CLAUDE CODE
=======================================
Actualizado: 13 de noviembre de 2026 (Área 5: 2b parte 2 y lo de la etapa 3 que no depende de la app)

CÓMO USAR ESTE ARCHIVO
----------------------
- 6 áreas (0 a 5). Cada área es un chat de Claude Code en su propia rama; cada etapa, una conversación nueva.
- Pega solo la etapa que toca. Elige el modelo de su línea "Modelo:" con /model (Sonnet es el de por defecto).
- Al terminar, trae el resumen al proyecto. Solo un chat a la vez compila o usa un teléfono.
- Lo hecho se borra de aquí: queda en docs/ESTADO.md, en git y en el archivo oldiechat-pendientes-historial-2026-11-09.txt (fuera del proyecto). Lo aprendido que sirve después pasa a "Datos confirmados".
- Se actualiza una vez al cerrar cada tema.
- Principios y productos: en CLAUDE.md y en las instrucciones del proyecto. Aquí no se repiten.


>>> EN CURSO <<<
[ ] SIGUIENTE: Investigación de Android (Área 2, etapa 1), en un chat nuevo del proyecto (sin Claude Code).
[ ] Respaldar en GitHub: cd ~/Projects/OldieChat y git push origin main motor sms (incluye los commits del 13-11-2026). Sin etiqueta ni Release.
[ ] Android 4.4 del Core 2: solo en el respaldo ~/Respaldos/core2-stock-oldiechat. La sesión de la terminal sirve si se restaura antes del 08-12-2026; después hay que vincular de nuevo con QR. No abrir OldieChat terminal en el Core 2 con Lineage. Pasos en Comandos.
[ ] Chip del Core 2: no toma la red de Movistar (solo Claro y WOM) y con Lineage solo sirve la ranura 1. Cuando la puerta de enlace pase al Core 2, decidir entre portar el número a Claro o WOM ($50 por SMS) o un chip nuevo. Sin plata por ahora.
[ ] Saldo del chip Movistar del Fame: unos $230 (unas 3 respuestas), vence el 02-12-2026. Sin recargar hasta que haya plata. La línea se pierde con 180 días sin recargar (plazo: mayo de 2027).

Estado de los teléfonos (13-11-2026):
- Fame: pantalla rota y sin táctil, solo por ADB. Bloqueo de pantalla desactivado (respaldo en /data/system/locksettings.db*.orig). Chip Movistar prepago sin PIN, datos móviles apagados. Sin sesión de la terminal (el programa sigue instalado). Motor vinculado sin root en /data/local/tmp/oldiechat-engine/ ("Otro dispositivo" en el iPhone), con archivados (motor del 08-11-2026, 19:07). En /data/local/tmp: sms-bridge.sh del 13-11-2026 y player.jar. Sin dueño registrado: al arrancar sin número muestra la clave de 4 dígitos. Queda el marcador viejo de bienvenida sms-bridge-993359016 (el registro lo borra). Es la puerta de enlace de prueba. Vigilar: se reinició solo el 08-11-2026 ("reboot by NPON", sin causa).
- Core 2: LineageOS 15.1 Go (Android 8.1, 32 bits, sin Google, Magisk). Teléfono de prueba de Android 8.1 (motor y app) y de uso diario. Datos y prohibiciones en CLAUDE.md (7aa7761) y en "Datos confirmados".


====================================================================
DIRECCIÓN
====================================================================

Filosofía: minimalismo digital en todo: el uso, el código, el motor, los archivos y mi cabeza. Keep it simple.

Reglas (también en CLAUDE.md):
- Antes de una idea nueva o un cambio de dirección, Claude pregunta si es necesaria y si encaja. Lo que no encaja se borra.
- No vender nada conectado a WhatsApp.
- Un teléfono de prueba se compra solo para reemplazar uno que dejó de servir, usado y barato, y que corra lo que ya existe.
- Costo de OldieChat SMS: lo decide cada usuario. Son dos líneas con SMS (cliente y puerta de enlace): planes de 500 SMS al mes en uso normal, 1.000 en intenso. OldieChat usa la menor cantidad posible y el README muestra el costo y las condiciones de las cuatro compañías, sin recomendar ninguna.
- Terminal en mantenimiento desde la 0.2.3. Van en la terminal: arreglos de lo que existe, whatsmeow, Go, certificados, phone-test.sh, seguridad y respaldo. Van a la app: teclado físico, vincular en pantalla e imágenes. Lo nuevo, chico y necesario a diario se consulta. Que la terminal funcione perfecto en cada modelo no es prioridad.
- Publicar una versión solo cuando whatsmeow lo obligue o haga falta para usuarios. Mientras, a main como X.Y.Z-dev y git push origin main.
- Textos para personas (README, CHANGELOG, app y SMS) los escribe el usuario; Claude da los datos y, si se lo piden, revisa ortografía y largo o propone opciones. Los documentos técnicos (docs/ESTADO.md, MAINTAINING.md) los escribe Claude.
- La app y el motor vinculan solo con el código de 8 caracteres. Si WhatsApp lo quita, el QR vuelve desde el commit f2b76b2. La terminal sigue con el QR de nchat.
- ROMs: OldieChat no recomienda ni depende de una ROM. El Core 2 con Lineage reemplaza a un Android 8 original de 32 bits, solo para pruebas.

Dónde queda OldieChat:
1. Android que WhatsApp dejó fuera (exige Android 6.0 desde el 08-09-2026): OldieChat corre en 4.x y 5.x, mientras llamen en las redes actuales.
2. Android con WhatsApp, en versión mínima: sin segundo plano, sin notificaciones, sin estados ni canales, para teclas y liviano.
3. Dumbphones sin Android: solo con OldieChat SMS.

Prioridades: 1) minimalismo digital; 2) Android, empezando por el Fame y el Core 2; 3) OldieChat SMS (lo único que llega a los dumbphones sin Android); 4) versión de Android más popular y máxima compatibilidad; 5) Cloud App, solo investigar a futuro; 6) sin ideas nuevas ni cambios estructurales.

Orden de trabajo (por presupuesto, primero lo gratis; 13-11-2026):
1. Investigación de Android (Área 2, etapa 1), en el proyecto. ← SIGUIENTE
2. Memoria del motor (Área 1, etapas 5 y 6).
3. App Android (Área 4), con el piso que diga la investigación.
Hecho: Área 5, etapa 2b parte 2 (11-11-2026) y lo de la etapa 3 que se hace en sms-bridge.sh (13-11-2026). Lo que falta de la etapa 3 depende de la app o de textos.
En pausa por presupuesto: Área 5, etapa 4, la prueba real de los informes de entrega y el mes con un dumbphone.
En espera: kernels emulados (Área 1, etapa 3) y pendientes de la 0.2.4 (Área 0).
Core 2 con Lineage 8.1: Área 2, etapas 2 y 3, y Área 4. Core 2 con Android 4.4 (restaurar antes): su 1001 con SELinux (Área 5) y phone-test.sh de la 0.2.4 (o basta el Fame).

Actualizaciones de whatsmeow: no se actualizan solas en los teléfonos. Cada cambio es una versión nueva: update-whatsmeow.sh → build.sh → phone-test.sh → publicar → cada usuario corre install.sh. Esa versión publica también lo que esté en main. Mientras no exista la alerta semanal, correr scripts/check-go-version.sh cada cierto tiempo. Semanas de atraso sí, meses no. whatsmeow pedirá Go 1.27 cerca de febrero de 2027.

Créditos: wsp --version dice "OldieChat X.Y.Z (c) 2026 John Jethron / Basado en nchat (c) Kristofer Berggren / Licencia GNU GPL v3". La mención a nchat se mantiene mientras se use su código. Los avisos de whatsmeow (MPL 2.0), Go y otras librerías van en el archivo de licencias.

Qué cubren los teléfonos de prueba:
- Cubren: kernel 3.0 (Fame) y 3.10 (Core 2), Android 4.1 (Fame), 8.1 de 32 bits sin Google (Core 2 con Lineage), 4.4 con SELinux Enforcing (Core 2, solo con el respaldo), 512 a 768 MB de RAM, SMS con root.
- No cubren: Android 8 original, 9 y 10 de 32 bits, 64 bits (ARM64), ejecutar sin root en Android 10+ y 4G.

Uso de Claude Code:
- docs/ESTADO.md es la única memoria entre conversaciones: "terminamos por hoy" es obligatorio. Uno solo, también al unir sms con main.
- Opus para proponer: diseño, diagnósticos, Go en kernels antiguos, motor y parches a nchat. Sonnet para ejecutar lo aprobado. Si Sonnet sale mal, se repite con Opus.
- Modo sin preguntas (13-11-2026): para dejarlo trabajando solo, el prompt dice que decida lo reversible, anote sus decisiones en docs/ESTADO.md y deje como pendiente lo irreversible. Con Shift+Tab en el modo que no pide permiso.
- Soluciones y diseño primero en el proyecto (claude.ai). Un chat nuevo del proyecto por cada tema grande.
- /compact si una etapa se alarga. Una etapa grande se divide en partes, cada una en su conversación.
- Si la API corta a mitad de una prueba en el teléfono: pedir una captura antes de enviar otra tecla.
- Claude Code no copia archivos de la sesión al PC sin preguntar.
- SMS sin gastar saldo: SMS falsos con content insert como root y el puente con -t y -s. Ningún SMS real hasta que haya plata.


====================================================================
DATOS CONFIRMADOS
====================================================================

Redes y compañías en Chile:
- Entel apagó su 2G en 2024 y planeó pasar su 3G de 1900 MHz a 4G en el primer semestre de 2026 (el Fame y el Core 2 probablemente no tienen red Entel). Faltan las fechas de Movistar, Claro y WOM. Bandas 4G de Chile: 2, 4, 7 y 28.
- Costo por SMS enviado en prepago: Entel, Claro y WOM $50; Movistar $70. Recibir es gratis. No hay descuento entre la misma compañía.
- Planes con SMS (sitios oficiales, noviembre 2026): no existe plan solo de SMS; nada se puede vender como "ilimitado" (Subtel, 2018). Movistar Plan voz Libre $8.990 con 500 SMS y $9.990 con 1.000 (referencia del README); Movistar Libre 350 $12.990 con 500; Claro Plan S $9.990 con 500; WOM Plan W $10.990, SMS libres a 300 números distintos; Entel Plan Fácil prepago $8.000 por 30 días con 400. Los planes de $3.990 son para adultos mayores y no traen SMS. Mínimo real: unos $9.000 al mes por línea.
- Condiciones: Movistar y Claro dicen SMS de persona a persona, de terminal a terminal (Claro prohíbe envíos por software en Gigas Libres; Movistar prohíbe reventa). Entel y WOM no tienen cláusula explícita. La puerta de enlace (un teléfono, un solo número, bajo volumen) es zona gris de bajo riesgo.
- Prepago Movistar: recarga en ww2.movistar.cl/recarga con Webpay. De $100 a $4.999 vence en 30 días. La línea termina con 180 días sin recargar. Desde el 20-08-2026 toda línea prepago nueva se registra con identidad.
- Portabilidad numérica (Ley 20.471): se cambia de compañía con el mismo número, también en prepago.
- Consultar un IMEI: *#06# y la página de cada compañía o multibanda.cl.

WhatsApp:
- Exige Android 6.0 desde el 08-09-2026 e iOS 15.5 desde el 30-11-2026. El Fame y el Core 2 no pueden ser teléfono principal.
- whatsmeow solo funciona como dispositivo vinculado: siempre hace falta un principal con WhatsApp oficial.
- Si el principal pasa 14 días sin usarse, se cierran los vinculados. Un vinculado sin actividad 30 días se desconecta. La ayuda oficial no define "uso": se supone abrir la app.
- Un mensaje no entregado se guarda cifrado hasta 30 días.
- Principal y puerta de enlace en el mismo teléfono: solo Android 6+, con el código de 8 caracteres (160 s para escribirlo). Riesgo: WhatsApp podría quitar el código; el README no debe prometer ese caso.
- Una sesión copiada es el mismo dispositivo vinculado: si dos teléfonos la abren, WhatsApp desconecta uno. Cerrarla desde el principal cierra las dos copias.
- Respaldo de la sesión de la terminal: deja de servir cuando la otra copia se usa. Restaurar necesita .config/nchat/version. Pesa unos 976 KB.
- Lista de vinculados del iPhone: "Otro dispositivo" = Fame con el motor; "Firefox (Linux)" = Core 2 con la terminal (sesión en el respaldo); "Google Chrome (Windows)" sin identificar.

Motor (engine/):
- Órdenes: pair (código), logout, chats (people o groups, con "archived":true), messages (nuevos por chat, marca vistos hasta el último) y send. Evento message con el dispositivo (0 = principal, sirve para el aviso de 14 días).
- Sin confirmaciones de lectura: los chats no se marcan como leídos en el principal.
- Chats con LID; el número se guarda cuando se conoce. Tope de 50 mensajes por chat; al vincular llegan unas 3 semanas de historial.
- Etiquetas iguales a la terminal ("imagen 45 KB", "link" y dominio, etc.). --glyphs sms entrega GSM de 7 bits sin emoji. media/ se borra al arrancar y al cerrar.
- 13 MB de RAM (RSS) con el puente en el Fame.
- Sin probar: cambio de nombre de grupo, "ubicacion" y "contacto". Vigilar: el primer mensaje después de vincular no llegó.

Fame (Android 4.1, kernel 3.0):
- Serie 4d009ce074228000. ADB no pide autorizar el PC. No trae cp, chown -R ni grep. rm no acepta -f.
- SMS con root: Samsung rechaza envíos desde uid 0; se envía como radio (su 1001). TMPDIR=/data/local/tmp para scripts con su. content query tarda unos 0,73 s y lanza una máquina Dalvik nueva cada vez. Con root se insertan y borran SMS y llamadas falsos.
- mksh R40: sin read -t, $'\1' no funciona, la barra invertida escapa en patrones y el final de una tubería corre en un subshell.
- SuperSU no copia los grupos al cambiar de usuario: el motor perdía internet. Por eso el puente corre como shell y pide root solo para leer y enviar.
- Llamadas: a veces no llegan al módem (red). Las que llegan quedan como perdidas y el puente responde 2 s después.
- Los avisos de saldo de Movistar llegan al inbox; el puente los ignora.

Core 2 con Android 4.4 (en el respaldo):
- Kernel 3.10.17, SELinux Enforcing sin negaciones. Firmware G355HUHS0APH1. Versión mexicana, IMEI inscrito en Chile; solo ve Claro y WOM.
- Samsung 3.10 trae CONFIG_SEC_RESTRICT_FORK: un proceso root con ejecutable en /data no lanza otros programas. Solución: oldiechat.sh corre nchat desde /dev/oldiechat.
- SuperSU en 4.4 (daemonsu) da a nchat una terminal propia: se arregló con el parche 0014 (OLDIECHAT_TTY).
- El reproductor de Samsung no escribe createTrack; phone-test.sh acepta "Received MEDIA_STARTED".
- Root: TWRP 3.0.0-0 (XDA, hilo de Y300-0100) con Heimdall (partición RECOVERY) y SuperSU 2.82-SR5 instalado desde /sdcard. Respaldos en el PC: ~/Respaldos/core2-twrp (Boot, System, EFS) y ~/Respaldos/core2-stock-oldiechat (con Data y la sesión).

Core 2 con LineageOS (09-11-2026):
- lineage-15.1-20240308-UNOFFICIAL-kanas (Go, Android 8.1, API 27, 32 bits), low_ram=true, sin Google Play Services, Magisk v30.7, TWRP 3.7.0 no oficial. Serie 4203ce4abc349100.
- Spreadtrum SC8830, 4 núcleos a 1,2 GHz, 768 MB (670 visibles), unos 1,4 GB libres, almacenamiento lento.
- Ajustes del usuario: 3 procesos en segundo plano (script de Magisk), zram 256 MB, animaciones en 0, tema oscuro, galería, cámara y navegador desactivados (WebView activo).
- Solo la ranura SIM 1. Al reiniciar a veces se apaga. El ADB de TWRP no funciona.
- Prohibido: flashear o escribir en particiones, cambiar ajustes, activar o desactivar paquetes, tocar el script de Magisk, desinstalar apps del usuario, tocar ~/Respaldos o ~/Descargas/core2.
- Sin probar: OldieChat en esta ROM.

App Android:
- SMS sin root: RECEIVE_SMS, READ_SMS, SEND_SMS, READ_CALL_LOG e INTERNET. Desde Android 4.4 solo la app de SMS predeterminada borra SMS; OldieChat no lo será.
- Verificación de desarrolladores de Google: en 2027 llega a todo el mundo, en dispositivos certificados con Android 7+. Se instala igual con ADB o un flujo avanzado. Cuenta gratis de aficionado: hasta 20 dispositivos.
- Lección de TermOne Plus: el desplazamiento dentro de un mensaje largo no se repintaba; se arregló con redrawwin (parche 0013).
- TermOne Plus: Atrás en "Envía TAB al terminal"; con otra opción nchat queda vivo sin ventana.

Dumbphones e iPhone:
- Básicos 4G en tiendas chilenas (Mlab, Tecnolab, Bmobile, Fujita): $33.000 a $50.000, ninguno dice VoLTE. Nokia 4G sin venta oficial. Nokia 235 4G: solo la versión Europa/Asia-Pacífico trae bandas 7 y 28. "Nokia 105" tiene que decir 4G.
- En básicos, VoLTE se confirma solo probando con el chip. En muchos, # y los símbolos cuestan varias teclas: los comandos usan dígitos y letras.
- iPhone: no puede ser puerta de enlace ni instalar una app fuera de la App Store; sí sirve como cliente de OldieChat SMS. Jailbreak descartado.

Otros:
- GitHub desactiva los procesos programados después de 60 días sin cambios en el repositorio.


====================================================================
COMANDOS (en el PC, terminal fish)
====================================================================

Abrir:
  oldie                      entra a la carpeta del proyecto y abre Claude Code
  cd ~/Projects/OldieChat    siempre antes de git o gh
  claude                     conversación nueva (lo normal)
  claude --continue          retomar la última (solo si una etapa quedó a medias)
  claude --resume            elegir una conversación anterior

Dentro de Claude Code:
  Esc            interrumpir
  Shift+Tab      cambiar de modo (automático o que pregunte)
  /model         elegir Opus o Sonnet
  /usage         ver el límite de uso
  /compact       resumir si una etapa se alarga
  /btw <texto>   preguntar sin interrumpir
  continúa       si la API corta una respuesta
  Ojo: fuera de Claude Code (prompt ❯ de fish), lo que escribes es un comando.

Git:
  git status / git log --oneline -5 / git branch
  git push origin main motor sms     respaldar las tres ramas

Compilar:
  time ./build.sh > build.log 2>&1   unos 4 min con la caché de work/ (no borrarla)

Teléfono:
  adb devices                 con dos teléfonos, usar adb -s o ANDROID_SERIAL (Core 2: 4203ce4abc349100; Fame: 4d009ce074228000)
  adb shell                   entrar; exit para volver
  Los comandos con | grep van en el PC.
  Core 2 con Lineage: root con adb -s 4203ce4abc349100 shell su -c "..."; si se reinicia y se apaga, encenderlo a mano.
  Chat de prueba: Saved Messages. Claude Code llega tocando su nombre en la lista.

Vincular el motor: en el iPhone, Dispositivos vinculados > Vincular un dispositivo > Vincular con número de teléfono; escribir el código antes de 160 s.

Sesión de la terminal (con OldieChat cerrado):
  ANDROID_SERIAL=<serie> ./session.sh respaldar
  ANDROID_SERIAL=<serie> ./session.sh restaurar <archivo>   solo en un teléfono sin sesión

Puente SMS (en el Fame):
  adb shell sh /data/local/tmp/sms-bridge.sh -t -s +569XXXXXXXX
    -t no envía SMS (gratis); -s WhatsApp solo a Saved Messages; sin -t cada SMS cuesta $70
    Con número en la orden: sirve para pruebas y no se guarda. Sin número: usa el dueño guardado en sms-bridge-owner; si no hay, muestra la clave de 4 dígitos.
  adb shell ps | grep sms     al terminar no debe mostrar nada
  Registros con chats reales: /data/local/tmp/sms-bridge.log y sms-bridge-motor.log; borrarlos al terminar.
  Llamada perdida: llamar desde el iPhone y cortar a los 2 o 3 tonos.

Core 2: volver a Android 4.4:
  El ADB de TWRP no funciona: copiar el respaldo con Lineage encendido.
  du -sh ~/Respaldos/core2-stock-oldiechat    revisar que quepa en unos 1,4 GB libres; si no, usar una microSD
  adb -s 4203ce4abc349100 push ~/Respaldos/core2-stock-oldiechat/BACKUPS/ /sdcard/TWRP/BACKUPS/
  adb -s 4203ce4abc349100 reboot recovery
  En TWRP: Restore → core2-stock-oldiechat → Boot, System, Data y EFS → deslizar → Reboot System.
  Revisar que TWRP 3.7.0 lea el respaldo hecho con TWRP 3.0.0. Si el pull dejó las carpetas sin BACKUPS/, ajustar la ruta.

Publicar una versión (Claude Code crea la etiqueta):
  git push origin main vX.Y.Z
  gh release create vX.Y.Z out/oldiechat-terminal-X.Y.Z-armv7.tar.gz out/oldiechat-terminal-X.Y.Z-armv7.tar.gz.sha256 out/oldiechat-terminal-X.Y.Z-source.tar.gz out/oldiechat-terminal-X.Y.Z-source.tar.gz.sha256 --title "OldieChat terminal X.Y.Z" --notes (sed -n '/^## X.Y.Z/,/^## <versión anterior>/{//!p}' CHANGELOG.md | string collect)
  Si se corta: Ctrl+C y gh release upload vX.Y.Z <los 4 archivos> --clobber

Rutina al empezar: oldie → /model → "Lee docs/ESTADO.md." y pegar la etapa → modo automático.
Rutina al terminar: "terminamos por hoy" en Claude Code → git push (opcional) → traer el resumen al proyecto.


====================================================================
[ ] ÁREA 0 - VERSIONES
====================================================================
Publicada: 0.2.3 (07-11-2026, v0.2.3 en 90471cd).

[ ] 0.2.4 (en main como 0.2.4-dev). Se publica con la próxima actualización de whatsmeow.
    Ya en main: session.sh respaldar y restaurar; install.sh avisa versiones y se detiene si OldieChat está abierto; home/ root:root 700; nchat desde /dev/oldiechat (audio en Samsung 3.10); parche 0014 (teclado en 4.4); phone-test.sh acepta MEDIA_STARTED; motor conectado; README con "Plazos de WhatsApp"; CLAUDE.md con el Core 2 con Lineage.
    Pendientes antes de publicar:
    - phone-test.sh en Android 4.4 (restaurar el Core 2) o basta el Fame.
    - glyphs.txt generado en cada teléfono por install.sh con scripts/glyphs.sh. Si exige instalar algo más en el PC del usuario, consultar antes.
    - phone-test.sh probando el audio desde un nchat que corre como root.
    - audio.log con la hora local y no UTC.
    - CHANGELOG: lo escribe el usuario.


====================================================================
[ ] ÁREA 5 - OLDIECHAT SMS (PUERTA DE ENLACE) (ACTIVA)
Chat nuevo. Rama: sms
====================================================================

Objetivo: que cualquier teléfono que envía SMS use OldieChat a través de un teléfono con OldieChat como enlace, lo más instantáneo posible y con la menor cantidad de SMS. Se prueba en el Fame (scripts/sms-bridge.sh) y después pasa a la app (Área 4, etapa 6). Diseño completo en docs/SMS_BRIDGE.md. La rama sms ya tiene main y motor; todavía no se une a main.

Ya funciona en el Fame:
- 2a y 2b parte 1: llamada perdida o 0 = menú; 00 = lo nuevo de las 9 personas en 1 SMS; n = abrir; n texto = responder; texto solo = a la última persona; g = grupos; gn = últimos 3 del grupo; gn texto = escribir al grupo; a = ayuda. Archivados ocultos. Silencio si sale bien y [OK] en el menú siguiente; [NO SE ENVIO] si falla. Respuestas siempre al número del dueño. Límite de 30 SMS por hora, guardado en archivo. Responde 2 a 3 s después de que llega el SMS.
- 2b parte 2 (11-11-2026): modo conversación (20 s para juntar, se cierra con 10 minutos sin SMS del dueño), informes de entrega (sin prueba real) y aviso de 14 días.
- Etapa 3 en el script (13-11-2026): registro del dueño con clave de 4 dígitos (el número que la envía queda guardado en sms-bridge-owner; a la clave no se responde). La bienvenida va con el logo de 2 filas en el primer pedido donde cabe; si el primer pedido es a, va en el siguiente. En chats de personas (n y modo conversación) el primer nombre va una vez arriba, las líneas de la persona sin nombre y las mías con "Yo:"; ahorra 16 septetos en un chat de 5 mensajes (hasta 41 si todos son de la persona y el nombre es largo). En grupos, el nombre en cada línea.
- Medidas: toda respuesta pedida cabe en 1 SMS (ayuda 158, menú con bienvenida 116, menú solo 87). Una tanda del modo conversación puede usar hasta 3 partes.

Diseño vigente (docs/SMS_BRIDGE.md):
- Menú: solo personas, las 9 más recientes con no leídos, sin segunda página. El logo solo en la bienvenida y la ayuda. Con 9 personas cabe en 1 SMS.
- Grupos a pedido con g; nunca se reenvían solos.
- Modo conversación: reenvía lo nuevo de una persona juntando 20 s; termina con 10 minutos sin SMS del dueño.
- Aviso de 14 días: desde la última señal del principal; desde el día 12, una línea de aviso en la siguiente respuesta.
- Sin root (app): escucha solo con la pantalla del modo SMS abierta, al frente, encendida, brillo mínimo y fondo negro; la puerta de enlace queda enchufada. Sin servicio en segundo plano.
- Cuota: uso normal unos 420 SMS del dueño y 390 de la puerta de enlace al mes; intenso unos 840 y 780.
- Menú de inicio del teléfono de enlace: "OldieChat App" y "OldieChat SMS [enlace]".
- Criterios: llega todo, en orden, sin duplicados y en segundos; responder cuesta lo mismo que un SMS normal; se sabe quién escribe; la menor cantidad de SMS posible.

Descartado (no volver a proponer): compresión, USSD, MMS, SMS largos, RCS, menú por llamada de voz, sistema propio para básicos, PIN, recomendar compañía, ser la app de SMS predeterminada, # y ? como comandos, abrir WhatsApp solo, emojis como texto, etiquetas abreviadas, segunda página del menú, grupos o archivados como puestos del menú, aviso de SMS restantes ("Quedan N SMS", borrado de SMS_BRIDGE.md el 13-11-2026) y esconder archivados en el motor.

Sin resolver: si el segundo plano del principal cuenta para los 14 días; su 1001 con SELinux en el Core 2 con 4.4; memoria de la puerta de enlace (Área 1, etapa 5); si hacen falta "Sin internet desde HH:MM" y avisar lo pendiente de más de 10 minutos al abrir (están en SMS_BRIDGE.md sin programar; si no son necesarios, se borran).

[ ] ETAPA 3 - CONFIGURACIÓN SIMPLE (lo que falta depende de la app o de textos)
- Menú de inicio: "OldieChat App" u "OldieChat SMS [enlace]" (app).
- Puerta de enlace: vincula WhatsApp con el código de 8 caracteres (Área 4, etapa 3), y la pantalla muestra la clave de 4 dígitos y el número de la puerta de enlace (app).
- Carácter de OldieChat SMS (pedido del usuario): que los SMS se parezcan más a la app (logo, estilo, forma de mostrar el menú y los mensajes). Condición: no agregar SMS ni caracteres que suban el costo.
- Palabras distintas de la terminal: decidir (ver Textos de los SMS).
- Resumen imprimible de 5 líneas: llamar y cortar = ver chats; número + texto = responder; texto solo = a la última persona; g = grupos; 0 = volver. El texto lo escribe el usuario.
- Sin SMS reales.

[ ] ETAPA 4 - VALIDAR CON WHATSAPP REAL (EN PAUSA POR PRESUPUESTO)
Cuando haya plata: unos días de uso normal con los criterios de arriba, incluida la prueba real de los informes de entrega y un registro real del dueño (ver cómo llega el número). Si convence, el mes con un dumbphone como teléfono principal.


====================================================================
[ ] ÁREA 1 - MOTOR FIRME Y LIVIANO (ACTIVA)
Chat nuevo. Rama: motor
====================================================================

Objetivo: que el motor no falle en kernels antiguos, use poca memoria y quede conectado a WhatsApp, como base de la app y de la puerta de enlace. Compila bastante: no la corras al mismo tiempo que otra que compile.

Orden: 5 → 6 → 3 → 4 → 8. Las etapas 5 y 6 van después de la investigación de Android. La 3 puede adelantarse (no necesita teléfono).

[ ] ETAPA 3 - KERNELS EMULADOS
Crea un entorno de prueba con un kernel Linux 3.0 emulado en qemu-system-arm. Debe probar lo que usa el motor: goroutines, timers, red, DNS, TLS, archivos, SQLite y crypto/rand, y registrar cualquier llamada al sistema que falle (ENOSYS). El kernel 2.6 queda fuera.

[ ] ETAPA 4 - ALERTA SEMANAL
Modelo: Opus
Un proceso semanal (GitHub Actions si es viable) que actualice whatsmeow a su versión más reciente en la terminal y en engine/ con un solo paso, lo compile con la versión más reciente de Go, incluidas beta y release candidate, aplique los parches y pruebe en los kernels emulados.
Aviso por correo (el de mi cuenta de GitHub) en los dos casos:
- Si todo pasa: un aviso corto con la versión nueva de whatsmeow, o "sin cambios" si no hubo versión nueva.
- Si algo falla: un issue con el error, que también llega por correo.
GitHub desactiva los procesos programados después de 60 días sin cambios en el repositorio: propón la forma más simple de que la alerta no se apague sola. Dime qué tengo que activar en github.com → Settings → Notifications.
phone-test.sh sigue siendo la confirmación final en los teléfonos reales.

[ ] ETAPA 5 - MEDIR MEMORIA
Mide cuánta RAM y almacenamiento usa el motor en el teléfono de prueba: en reposo, al recibir mensajes, al reproducir un audio, durante la sincronización inicial y como puerta de enlace SMS. Propón un presupuesto (máximo en reposo y en uso) que permita funcionar en teléfonos de 256 MB, y optimizaciones: limitar el historial sincronizado (opción de días del historial reciente, RecentSyncDaysLimit, si la sincronización usa mucha memoria; hoy llegan unas 3 semanas con tope de 50 mensajes por chat), GOMEMLIMIT, caché de SQLite y quitar del binario lo que no se usa. Los adjuntos ya se borran al salir y el motor borra media/ al arrancar y al cerrar. Dato del 08-11-2026: con el puente SMS corriendo, el motor usaba 13 MB (RSS) en el Fame. Muéstrame mediciones y propuesta antes de aplicar.

[ ] ETAPA 6 - APLICAR EL PRESUPUESTO
Aplica las optimizaciones aprobadas. Que phone-test.sh mida la memoria y falle si se supera el presupuesto. Documenta el presupuesto en MAINTAINING.md y dame los datos para el README (lo escribo yo).

[ ] ETAPA 8 - IMÁGENES (MOTOR)
Al llegar una imagen, el motor la reduce a un tamaño y calidad pequeños para pantallas de 3,5" o menores y borra el original. La imagen reducida se borra al salir, con la misma regla de los adjuntos. Mostrarla es trabajo de la app (Área 4, etapa 5): la terminal no cambia. Revisa primero si se reutiliza lo de los audios y muéstrame la propuesta antes de implementar.


====================================================================
[ ] ÁREA 2 - COMPATIBILIDAD ANDROID (ACTIVA)
Chat nuevo. Rama: retrocompat
====================================================================

Objetivo: que OldieChat funcione en la mayor cantidad de teléfonos Android que llaman en las redes actuales: Android con teclas y Android 4G reutilizados.

[ ] ETAPA 1 - INVESTIGACIÓN (en el proyecto, sin Claude Code) ← SIGUIENTE
- Versión de Android más popular entre Android con teclas y Android 4G reutilizados en Chile y Latinoamérica.
- Candidatos con teclas: Xiaomi Qin F22 Pro, Cat S22 Flip, Mudita Kompakt y otros.
- Candidato fuerte con teclas (09-11-2026): AGM M7, en AliExpress a unos $130.000 con IVA. Android 8.1 simplificado sin Play Store (instala APK), MediaTek MT6739, 1 GB de RAM, 2,4" QVGA táctil, cruceta. Versión americana: 4G en bandas 2, 4, 5, 7 y 28. Confirmar: VoLTE en Chile (el fabricante dice "soporte limitado") y 32 o 64 bits. Correría OldieChat App directo, con una sola línea. Comprar solo con la app funcionando y con plata. Versión americana: código AM7USBL01 (T-Mobile); sin stock en la tienda oficial ni en eBay, y AliExpress solo tiene EUR, UK, RU y AU (bandas europeas: en Chile solo 7 y 28). Sin venta en Chile (09-11-2026). Revisar si la versión europea sirve según las bandas de cada compañía.
- Candidatos reutilizados: Samsung Galaxy J2 Prime, J5, J7, A10, A01; Motorola Moto E5, G5, G6; Huawei Y5, Y6, Y7; Xiaomi Redmi 5A, 6A, 7A, 9A.
- Por cada uno: versión de Android, 32 o 64 bits, RAM, bandas 7 y 28, VoLTE en Chile, tamaño y resolución de pantalla, y si todavía corre WhatsApp oficial.
- Requisitos mínimos propuestos: Android 5 o más nuevo, 4G con bandas 7 y 28, 1 GB de RAM o menos sin problema, VoLTE.
- Piso de la app: si incluir Android 4.1 (el Fame) agrega peso.
- Fechas de apagado del 3G de Movistar, Claro y WOM, y VoLTE por compañía (el Fame y el Core 2 solo tienen 3G 850/1900).

[ ] ETAPA 2 - ANDROID MODERNO DE 32 BITS
Modelo: Opus
Prueba el motor en el Core 2 con LineageOS 15.1 (Android 8.1, 32 bits; serie 4203ce4abc349100) por ADB, sin root y sin instalar nada permanente fuera de /data/local/tmp. Respeta la lista de prohibiciones del Core 2 en CLAUDE.md. Prueba también en emuladores de Android 9 y 10 de 32 bits (ARM o x86 de 32 bits si ARM no corre), y en uno reciente de 32 bits si existe. Confirma si el filtro de llamadas al sistema (seccomp) de Android cierra el proceso. Si lo cierra, identifica la llamada y propón la solución más pequeña.
Evalúa también compilar el motor para Android (GOOS=android) en vez de Linux genérico, para que Go evite las llamadas que Android bloquea. Compara las dos compilaciones en el Fame, en el Core 2 y en los emuladores, y dime si una sola sirve para todos.
Muéstrame el resultado antes de cambiar código.

[ ] ETAPA 3 - COMPILACIONES POR PROCESADOR
Que build.sh genere el motor para cada procesador que pida la investigación (ARMv7, ARM64), sin duplicar código.
Un solo binario PIE por procesador: Android 5 en adelante exige PIE y Android 4.1 ya lo acepta, así que el mismo binario debería servir para el Fame, el Core 2 y los teléfonos nuevos. Confirma que funciona con la compilación estática de hoy (musl) y pruébalo en el Fame (4.1) y en el Core 2 con Lineage (8.1) antes de cambiar build.sh.

[ ] ETAPA 4 - PHONE-TEST.SH PARA CUALQUIER TELÉFONO
Que funcione en cualquier Android soportado, detecte versión de Android, kernel, procesador y RAM, y lo anote en el resultado.
Mínimo de pantalla: mide en el teléfono de prueba cuántas columnas y filas de texto necesita OldieChat para verse bien (lista de chats, conversación, guía y el código de vinculación). Ese número pasa a ser el requisito de pantalla. Que phone-test.sh anote las columnas y filas del teléfono y avise si no llega al mínimo. Propón qué hace OldieChat en ese caso (ajustar la letra o avisar), lo más simple posible.

[ ] ETAPA 5 - TABLA DE TELÉFONOS COMPATIBLES
Tabla en el README con los modelos probados (Galaxy Fame GT-S6810L y Galaxy Core 2 SM-G355H, con Android 4.4 original y con LineageOS 15.1, marcado como ROM no oficial) y plantilla de issue en GitHub para reportar modelo, Android, kernel, procesador, RAM, pantalla (pulgadas, columnas y filas) y qué funcionó. El README indica el mínimo de pantalla y describe dónde queda OldieChat. Los textos del README los escribe el usuario; Claude da los datos y arma la tabla.
Sección "Qué teléfono usar", corta:
1. Reutiliza tu Android viejo.
2. Si no tienes, un Android usado barato que llame en las redes actuales.
3. Para un dumbphone de verdad: un básico 4G con OldieChat SMS. El Android viejo queda en casa, enchufado, como puerta de enlace; si tiene Android 6 o más nuevo, también puede ser el principal de WhatsApp.
Cómo elegir el básico: 4G con bandas 7 y 28, VoLTE probado con tu compañía, T9 en español y vista de conversación en los SMS.


====================================================================
[ ] ÁREA 3 - USUARIOS (TERMINAL EN MANTENIMIENTO)
Chat nuevo. Rama: usuarios
====================================================================

Objetivo: que OldieChat terminal sea seguro y fácil de instalar y actualizar. Las funciones nuevas van al Área 4.

[ ] ETAPA 4 - BATERÍA
Mide cuánta batería consume OldieChat abierto (en reposo, recibiendo mensajes y reproduciendo audio) y agrégalo a phone-test.sh si es posible.


====================================================================
[ ] ÁREA 4 - APP ANDROID (SE ACTIVA CON EL ÁREA 2, ETAPA 1)
Chat nuevo. Rama: app
====================================================================

Objetivo: OldieChat App en Java, sin root, simple y liviana, con la estética de terminal de OldieChat. Se usa solo con teclas, con el toque como ayuda en los táctiles. Hace de puerta de enlace SMS (Área 5).

Opción principal a evaluar: la app trae su propia terminal integrada (basada en Terminal Emulator for Android) y ejecuta dentro la interfaz de nchat de hoy. La alternativa es una interfaz Java propia que imite la terminal.

Teléfonos de prueba de la app: el Fame (Android 4.1) y el Core 2 con Lineage (Android 8.1, sin Google, low_ram, 3 procesos en segundo plano). En el Core 2 se revisan permisos en tiempo de ejecución (también los de SMS), que no haga falta segundo plano ni notificaciones, tema oscuro y uso de RAM.

Logo: la guía usa la versión de 2 filas; la pantalla de inicio de la app, la de 4 filas.

 o_o_o
( ^_^ ) OldieChat

[ ] ETAPA 1 - PISO DE ANDROID (SOLO DISEÑO)
Modelo: Opus
Lee docs/ESTADO.md y docs/APP_ARCHITECTURE.md. El piso lo define la investigación del Área 2. Considera:
- Android 5 en adelante exige ejecutables PIE (usar el binario PIE del Área 2, etapa 3).
- Sin AndroidX ni librerías que exijan versiones nuevas. Nada que dependa de servicios de Google.
- Cómo corre el motor sin root. Compara dos formas por peso, código y piso de Android:
  a) Programa aparte dentro de la carpeta de librerías nativas del APK, que Android 10 en adelante deja ejecutar.
  b) Librería que la app carga por dentro (Go como librería compartida), sin ejecutar un programa aparte.
  Recomienda una. Si la b obliga a cambiar la terminal integrada, dímelo.
- Android 14 en adelante: targetSdk reciente, solo si no agrega peso. minSdk, targetSdk y compileSdk deben permitir instalar en el Fame (API 16) y en el Core 2 (API 27).
- Permisos en tiempo de ejecución desde Android 6 (incluidos los de SMS).
- 32 y 64 bits, según el Área 2, etapa 2.
- Verificación de desarrolladores de Google: recomienda cómo distribuir el APK (ver "Datos confirmados").
- Permisos del modo puerta de enlace: RECEIVE_SMS, READ_SMS, SEND_SMS, READ_CALL_LOG e INTERNET.
- Pantalla: la app elige el tamaño de letra para llegar al mínimo de columnas y filas del Área 2, etapa 4.
- Si se prueba en el Core 2 con Android 4.4, pedir antes que se restaure su respaldo.

[ ] ETAPA 2 - ARQUITECTURA, PANTALLAS Y TECLADO FÍSICO (SOLO DISEÑO)
- Compara las dos opciones (terminal integrada o interfaz Java propia) por peso, código, piso de Android, teclados físicos y licencias. Recomienda una. Con interfaz propia ya no se usa código de nchat.
- Completa docs/APP_ARCHITECTURE.md: qué va en el APK, cómo se comunican las piezas (órdenes del motor: pair, logout, chats con archived, messages, send), compilación por procesador, DNS y certificados sin root, vinculación con el código de 8 caracteres y el modo puerta de enlace.
- Pantallas mínimas (inicio, menú de inicio, lista de chats, conversación, archivados, vinculación y ajustes), en texto, para pantallas de 2,4" a 3,5". Respeta el presupuesto de memoria del Área 1.
- Nombre OldieChat y logo del bufón, sin la marca WhatsApp. En los vinculados del principal hoy aparece como "Otro dispositivo": decidir si se deja así (cambiarlo obliga a vincular de nuevo).
- Emojis en pantalla: decidir qué hacer con los emoji sin línea R y el selector de variante según la fuente de la app.
- Teclado físico (prioridad alta). La app debe poder usarse solo con teclas: teclado numérico tipo Nokia, cruceta (arriba, abajo, izquierda, derecha, OK), dos teclas de función, llamar, colgar y borrar. Los botones de volumen siguen funcionando en los táctiles.
  1. Esquema de teclas (moverse por chats y mensajes, abrir, volver, enviar, archivados, buscar, guía, escuchar audio, salir) y escritura con multitoque. Misma lógica de hoy: moverse y acción.
  2. Lista los códigos de tecla de Android (KEYCODE_DPAD_*, KEYCODE_SOFT_LEFT, KEYCODE_SOFT_RIGHT, KEYCODE_CALL, KEYCODE_ENDCALL, KEYCODE_0 a 9, KEYCODE_STAR, KEYCODE_POUND) y cómo llegan a la app.
  3. La guía muestra también el esquema de teclado físico.
  4. Al implementar: prueba por ADB solo en Saved Messages (avísame antes). Si puedo conectar un teclado USB por OTG, dime cómo probarlo.
No escribas código. Muéstrame el diseño.

[ ] ETAPA 3 - PROYECTO, VINCULACIÓN Y PANTALLA DE INICIO
Proyecto Android en Java con el piso aprobado, con el motor para cada procesador. La lógica de vinculación ya está en el motor (orden pair); aquí va la pantalla. Vincular debe ser tan fácil como WhatsApp Web, sin PC ni ADB:
- Solo con el código de 8 caracteres: el usuario escribe su número, aparece el código y lo ingresa en el principal (Dispositivos vinculados → Vincular un dispositivo → Vincular con número de teléfono). Hay 160 s. Sirve también cuando el principal es el mismo teléfono (Android 6+).
- Instrucciones cortas y en español, escritas por el usuario.
- Pantalla de inicio: el logo de 4 filas centrado mientras arranca y se conecta, mínimo 1,5 s; si conectar tarda más, el logo se queda hasta que esté listo. Después: sin sesión, vinculación; con sesión, el menú de inicio.
- Comando simple de prueba (pedido del 09-11-2026): un script que compile la versión debug, la instale en fame, core2 o los dos (siempre con adb -s), abra la app y muestre el logcat filtrado por la app. Compilación incremental. Antes de tocar archivos de build, mostrar el plan y esperar el visto bueno.

[ ] ETAPA 4 - CHATS
Lista de chats y conversación de texto, incluidos grupos. Sincroniza lo pendiente al abrir. Archivados (el motor ya los marca). Mensajes largos legibles enteros (lo aprendido en el parche 0013).

[ ] ETAPA 5 - AUDIOS E IMÁGENES
Escuchar audios y mostrar las imágenes que reduce el motor (Área 1, etapa 8): en la conversación se ven como "imagen" con su tamaño en KB. Se borran al salir. La app no depende de la galería del sistema (en el Core 2 está desactivada).

[ ] ETAPA 6 - MODO PUERTA DE ENLACE
Llevar a la app el puente SMS de docs/SMS_BRIDGE.md, probado en el Fame (scripts/sms-bridge.sh). Enviar SMS con el paquete propio de la app (Samsung rechaza envíos sin paquete). Formar "audio mm.ss" en el motor o en la app. La pantalla de la puerta de enlace muestra T_COD, la clave de 4 dígitos y su número. Revisar antes cómo reciben y envían SMS capcom6/android-sms-gateway, vernu/textbee y httpSMS (solo para aprender, sin dependencias). Prueba en Android moderno: el Core 2 con Lineage, cuando tenga chip Claro o WOM.


====================================================================
TAREAS EN EL PROYECTO (sin Claude Code)
====================================================================

[ ] Investigación de Android (Área 2, etapa 1). ← SIGUIENTE
[ ] Textos de los SMS (los escribe el usuario): GSM de 7 bits, sin tildes; 160 caracteres es el límite de todo el SMS. El logo solo en la bienvenida y la ayuda.
    Ya escritos:
    - [BIENVENIDA] "El uso del SMS depende de ti. Dgtl Minimal es el camino :)" (58 de 60).
    - T_COD "Envia esta clave OldieChat por SMS:" (35 de 40), en la pantalla de la puerta de enlace antes de la clave (13-11-2026).
    Faltan, con su largo máximo:
    - [AYUDA]: respuesta a "a", con el logo. Unos 130 (el logo ocupa unos 27; confirmarlo con Claude Code).
    - [PIE]: última línea del menú y de la lista de grupos. 25.
    - [OK] + nombre: el último envío salió bien. 10.
    - [NO SE ENVIO] + nombre: WhatsApp rechazó un envío. 25.
    - [SIN NUEVOS] + nombre (en 00 va solo). 25.
    - [SESION CERRADA]: pedido con la sesión cerrada. 60.
    - "Yo": nombre de tus propios mensajes. 8.
    - Los de la 2b parte 2 (modo conversación y aviso de 14 días).
    Decidir palabras distintas de la terminal (anotadas en docs/ESTADO.md): "ayuda" en el SMS y "guía" en la terminal (la letra del comando es a); "Yo" en el SMS y "You" en la terminal; no leídos como (k) en el SMS y con marca y color en la terminal.
    Ojo: el README dice "DGTL MINIMAL" y la bienvenida "Dgtl Minimal"; decides si los igualas.
    Mensaje de entrada largo (171 caracteres, 2 SMS; para el README o la app): "OldieChat intenta mantener al minimo el cobro por SMS, empaquetando mensajes y siendo lo mas eficiente posible. El uso que le das depende de ti. DGTL MINIMAL es el camino."


====================================================================
TAREAS FUERA DE CLAUDE CODE
====================================================================

[ ] Revisar que el respaldo del Core 2 en el PC tenga el tamaño que mostró TWRP (du -sh ~/Respaldos/core2-stock-oldiechat).
[ ] Instrucciones del proyecto en claude.ai: cambiar la línea del Fame y agregar la regla de textos para personas y la de vinculación (texto en el chat del 09-11-2026).
[ ] Revisar en el iPhone el vinculado "Google Chrome (Windows)": si no es WhatsApp Web del Asus, cerrarlo.
[ ] En github.com → Settings → Notifications: correo activado para "Actions" e "Issues" (para la alerta semanal).
[ ] Preguntar a familia y amigos por un Android 4G guardado (ideal: un Samsung con Android 8 original, o uno de 64 bits). Si tiene Android 6+, sirve también para probar principal y puerta de enlace en el mismo teléfono. Gratis.
[ ] Primer dumbphone (EN PAUSA POR PRESUPUESTO): para un mes con OldieChat SMS como teléfono principal, después del Área 5, etapa 4. Necesita dos líneas con SMS.
    Candidato: Fujita FJ-200 4G (PC Factory, $34.990; bandas 4, 7 y 28; chip T107; 2,8").
    Antes de pagar, en la tienda con el chip: llamar y ver que siga en 4G, mandar un SMS, revisar capacidad de mensajes, borrar todo de una vez, vista de conversación, T9 en español y cuántas teclas cuesta escribir g, a y números.
    Segunda opción: Bmobile con bandas 7 y 28, o preguntar en una tienda Movistar.
    Descartados: Nokia 235 4G de AliExpress, Nokia 105 TA-1683 (2G), Xiaomi Qin, garaho japoneses.
    Comparar precios en solotodo.cl.
