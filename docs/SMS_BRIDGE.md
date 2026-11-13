# Puente SMS (diseño)

Área 5, etapa 1. Diseño; el prototipo con root es `scripts/sms-bridge.sh` y lo que ya
está programado se detalla en `docs/ESTADO.md` (Área 5). Los textos exactos de los SMS
son los de `sms-bridge.sh` (los escribe el dueño).

Palabras: **dueño** es quien usa el teléfono básico; **puerta de enlace** es el
Android con OldieChat App abierto en modo SMS y una línea propia.

## 1. Referencia (solo para aprender)

Revisado de memoria sobre su código público, no en esta etapa. Se revisa en el Área 4, etapa 6.

| Proyecto | Recibe | Envía | Lo que no tomamos |
| --- | --- | --- | --- |
| SMS Gateway for Android (capcom6) | receptor de `SMS_RECEIVED` | `SmsManager` en partes, con avisos de enviado y entregado | servidor local o en la nube, push, servicio permanente, webhooks |
| textbee | receptor de `SMS_RECEIVED`, lo sube a su API | `SmsManager`, ordenado por push desde su servidor | servidor, panel web, push |
| httpSMS | receptor de `SMS_RECEIVED` | `SmsManager` con avisos, ordenado por push | servidor Go, latidos, cifrado entre servidor y app |

Lo que sí tomamos:
- Recibir con el aviso `SMS_RECEIVED` (llega con el mensaje ya armado si venía en partes).
- Enviar con `divideMessage` y `sendMultipartTextMessage`, con aviso de enviado para saber si falló.
- Límite de envíos por hora.

Lo que no tomamos: los tres viven en segundo plano con un servicio y un servidor
externo. OldieChat no tiene servidor: el motor habla con WhatsApp y la app con la red de SMS.

## 2. Recibir y enviar

### Con root (prototipo en los teléfonos de prueba)

- Recibir: `content query` sobre `content://sms/inbox` cada 2 s, filtrando
  `_id` mayor al último y el número del dueño (probado en la etapa 0: 1-3 s).
- Enviar: `SmsSend` por `app_process` como uid radio (1001). Desde root sin
  paquete Android rechaza el envío (etapa 0).
- Llamada perdida: `content query` sobre `content://call_log/calls`, tipo 3 y número del dueño.
- Restricción de Samsung 3.10 (Core 2): el kernel mata procesos root que ejecutan
  programas guardados en `/data`. Regla: como root solo se ejecutan programas de
  `/system/bin` (`sh`, `content`, `app_process`, `su`); lo de `/data` solo se lee
  (script, `player.jar`). El motor (binario en `/data/local/tmp`) no necesita root
  y corre como usuario normal. El Fame (3.0) no tiene la restricción. Sin probar en el Core 2.
- `SmsSend` cambia a partes y aviso de enviado (hoy es una parte y sin aviso).

### Sin root (OldieChat App, paquete propio)

- Permisos del manifiesto: `RECEIVE_SMS`, `READ_SMS`, `SEND_SMS`, `READ_CALL_LOG`
  (más `INTERNET`, que no se pide al usuario). En Android 6 o más nuevo se aceptan
  una vez al abrir.
- Recibir: receptor de `SMS_RECEIVED` registrado por la pantalla al abrir el modo
  SMS y quitado al cerrarlo. No va en el manifiesto: con la app cerrada no despierta nada.
- Al abrir: lee el inbox desde el último `_id` atendido (guardado) para sincronizar lo pendiente.
- Enviar: `SmsManager` en partes, con aviso de enviado.
- Llamada perdida: mientras está abierta, observa el registro de llamadas; una
  perdida del número del dueño envía el menú.
- Los SMS de comandos se acumulan. Desde Android 4.4 solo la app de SMS
  predeterminada puede borrar SMS, y Android guarda solo en enviados lo que manda
  otra app. OldieChat no se hace app predeterminada (reemplazaría la app de
  mensajes y sumaría código). Resultado: comandos y respuestas quedan en un solo
  hilo de la app de mensajes de la puerta de enlace, unos 800 SMS al mes en uso
  normal (menos de 1 MB). Se borra ese hilo a mano una vez al mes. En 4.1-4.3 y
  con root se podría borrar solo, pero se usa la misma regla en todos.

## 3. Seguridad

- Registro del dueño (etapa 3): la pantalla de la puerta de enlace muestra un código de 4
  dígitos; el número que lo envía por SMS queda como dueño. No se responde al código: el
  primer pedido recibe la bienvenida. Solo cuenta un SMS llegado después de mostrar el
  código; para cambiar de dueño se borra el registro en la puerta de enlace.
- Se comparan los últimos 9 dígitos (con o sin +56).
- Todo SMS o llamada de otro número se ignora en silencio: no se responde ni se registra el contenido.
- Las respuestas van siempre al número configurado, no al remitente: quien falsifique
  el número del dueño no recibe nada. Solo podría enviar mensajes de WhatsApp a su nombre.
- Sin PIN (decisión del dueño): el riesgo queda escrito en el README (sección 15).
- Límite: 30 SMS por hora. Al llegar, la puerta de enlace calla hasta la hora siguiente.

## 4. Qué se envía

- Solo respuestas a lo que el dueño pide.
- Única excepción: el modo conversación con una persona (sección 6).
- Nunca: avisos de mensajes nuevos, estados, llamadas, grupos.

## 5. Grupos

- `g`: los 9 grupos más recientes, numerados, en 1 SMS.
- `gn`: los últimos 3 mensajes del grupo n en 1 SMS (cada uno recortado para caber).
- `gn texto`: escribe al grupo n.
- Nada de un grupo se envía sin pedirlo, ni en modo conversación.

## 6. Un solo hilo

- Todo llega del número de la puerta de enlace, en un solo hilo del teléfono básico.
- Cada mensaje reenviado empieza con el nombre de pila de quien escribe (hasta 8 letras).
- `n texto`: envía a la persona n del último menú.
- `texto` sin número: va a la última persona que el dueño abrió o a quien escribió.
- Los números del menú quedan fijos hasta que el dueño pide un menú nuevo.
- Modo conversación: empieza al abrir o escribir a una persona. Se reenvía solo lo
  nuevo de esa persona, juntando 20 s. Termina con 10 minutos sin SMS del dueño,
  con otro menú o al abrir otra persona.
- Si el texto empieza con número, el dueño escribe antes el número de la persona
  (`n texto`). Lo mismo para un texto que sea solo `0`, `a` o `g`. Un `00` responde el menú (el comando se quitó el 11-11-2026).

## 7. Mínimo cobro

Comandos (sin `#` ni `?`, que en muchos básicos cambian el modo o están en la
tabla de símbolos). Las letras valen en mayúscula o minúscula:

| Envía el dueño | Recibe | SMS dueño | SMS puerta |
| --- | --- | --- | --- |
| llamada perdida o `0` | menú: hasta 9 personas, `n Nombre (sin leer)` | 0 o 1 | 1 |
| `n` | mensajes sin leer de n (o los 3 últimos), 1 SMS | 1 | 1 |
| `n texto` / `texto` | nada si sale bien | 1 | 0 |
| `g`, `gn`, `gn texto` | sección 5 | 1 | 1 o 0 |
| `a` | ayuda con el logo, en 1 SMS | 1 | 1 |

Reglas:
- Empaquetar: varios mensajes en un SMS, uno por línea.
- GSM de 7 bits (160 caracteres por SMS, 153 por parte si va en partes): antes de
  enviar, á í ó ú pasan a a i o u; é, ñ, ü, ¿ y ¡ se quedan; los emojis se quitan;
  comillas tipográficas y `…` pasan a simples y `..`. Un solo carácter fuera de GSM
  baja el SMS a 70 caracteres.
- Mensajes largos en modo conversación: hasta 3 partes y `..` al cortar.
- Adjuntos: las etiquetas de la terminal (`imagen N KB`, `audio mm.ss`, `documento pdf N KB`) y su texto si tiene.
- Silencio si sale bien. Llamada perdida = menú, gratis para el dueño.
- Cada parte cuenta como un SMS en la cuota.

Estimación mensual (30 días):

| Uso | Por día | SMS dueño/mes | SMS puerta/mes |
| --- | --- | --- | --- |
| Ligero | 1 revisión: menú, abre 1 chat, 1 respuesta | 60 | 60 |
| Normal | 2 revisiones (llamada perdida, abre 2), 10 respuestas, 6 tandas recibidas en conversación, `g` y `gn` día por medio | 450 | 390 |
| Intenso | el doble del normal | 900 | 780 |

Son dos líneas con SMS: la del teléfono cliente (columna dueño) y la de la puerta
de enlace. Uso normal: 500 SMS en cada una. Uso intenso: 1.000 en cada una.

## 8. Las 5 causas de "se siente raro"

| Causa | Respuesta del diseño |
| --- | --- |
| Hablas con un menú | Los mensajes llegan con el nombre y se responden escribiendo; el menú aparece solo si se pide. |
| Cada paso cuesta | Llamada perdida gratis, silencio si sale bien, empaquetar. |
| Todo llega del mismo número | Nombre al inicio de cada mensaje; el README pide guardar el número como "WhatsApp". |
| Esperas sin saber | Todo error se responde; la llamada suena si la puerta de enlace tiene señal; si no llega el menú en 1 minuto, está cerrada o sin red (README). |
| Hay que recordar comandos | 4 formas: número, texto, `g` y `a`; la última línea del menú las recuerda; `a` cabe en 1 SMS y se puede guardar como plantilla. |

## 9. Cuenta principal

- (a) Principal en otro teléfono (hoy el iPhone): la puerta de enlace es un dispositivo vinculado.
- (b) Principal y puerta de enlace en el mismo Android 6 o más nuevo: OldieChat se
  vincula con el código de 8 caracteres. Confirmado en whatsmeow: `PairPhone`
  vincula sin código QR ni cámara (`engine/wa/wa.go` ya lo usa). WhatsApp muestra un
  aviso para escribir el código en Dispositivos vinculados; hay 160 s para hacerlo.

Aviso de 14 días. La puerta de enlace no puede saber cuándo se abrió WhatsApp en el
principal: whatsmeow no recibe ese dato. Forma más simple:
- Cuenta los días desde la última señal del principal y lo muestra en su pantalla.
- (a) Señal: un mensaje enviado desde el principal (dispositivo 0 de la cuenta del
  dueño); basta escribirse a sí mismo. A confirmar en el motor (Área 1, etapa 7).
- (b) Señal: el dueño abre WhatsApp desde una tecla de la pantalla de OldieChat; la app lo sabe.
- Desde el día 12 agrega `Abre WhatsApp o la sesion se cierra` a la siguiente respuesta pedida, una vez al día.
- Si WhatsApp cierra la sesión: ver 10.

Caso (b), convivencia:
- Son dos dispositivos de la misma cuenta: cada uno recibe todo y no se pisan.
  OldieChat no toca los archivos de WhatsApp.
- Leer en OldieChat marca como leído también en WhatsApp.
- Memoria: un Android 6 suele tener 1 GB o más; WhatsApp queda atrás y OldieChat al
  frente, que es el último que Android cierra. El consumo de OldieChat no está medido.
- Se silencian en Android las notificaciones de WhatsApp y de la app de SMS de ese teléfono.

## 10. Errores

Una línea, solo cuando el dueño pidió algo:

| Falla | Recibe el dueño |
| --- | --- |
| Sin wifi o sin internet | `Sin internet desde HH:MM`. Lo que escribió queda pendiente y se envía al volver (solo mientras está abierta). |
| Sesión cerrada por WhatsApp | `Sesion cerrada. Abre tu sesion en la app :)` Deja de atender hasta vincular. |
| WhatsApp rechazó un envío | `No se pudo enviar a Nombre` |
| Comando no entendido o sin destinatario | el menú |
| Sin red de SMS en la puerta de enlace | Nada: no puede responder. Reintenta una vez al minuto y lo muestra en su pantalla. |
| Puerta de enlace cerrada o apagada | Nada. La llamada no suena si está apagada. |

## 11. Línea de la puerta de enlace

- Datos móviles apagados: el plan no trae datos.
- Wifi de la casa; en Android 4.x, "Mantener wifi en suspensión: siempre".
- Buzón de voz y desvíos apagados: si contesta el buzón, la llamada perdida se cobra.
- Tono en silencio. Siempre en el cargador, en un lugar con señal.

## 12. Abierto en modo SMS sin segundo plano

- El modo SMS es una pantalla al frente con la pantalla encendida (opción de ventana,
  sin servicio ni bloqueo de suspensión aparte). Android no cierra la app al frente
  y, con la pantalla encendida, Android 6+ no entra en reposo profundo.
- Brillo mínimo de la ventana y fondo negro; el texto cambia de lugar cada tanto
  para no marcar la pantalla.
- Si se cierra (apagón, reinicio, llamada atendida), no vuelve sola: al abrirla
  sincroniza lo pendiente.
- Pendientes al abrir: los mensajes a personas o grupos se envían; los pedidos
  (menú, abrir chat) de más de 10 minutos se descartan sin responder.
- Prototipo con root: el script corre en TermOne Plus con la pantalla encendida.

## 13. Pantallas de 1,8" (160x128)

- Unas 18 a 20 columnas y 5 a 7 líneas: un SMS completo ocupa más de una pantalla.
- Lo importante primero: nombre al inicio, un mensaje por línea.
- Líneas del menú cortas: `n Nombre (k)`.
- El logo de 2 filas (26 septetos) va siempre en la bienvenida y en la ayuda (`a`); en las
  demás respuestas pedidas, solo si cabe en el mismo SMS.
  Bienvenida: la respuesta al primer pedido después de registrar el número del dueño.

## 14. Teléfono cliente

- Un básico guarda de 100 a 500 SMS en el teléfono y 20 a 50 en el SIM. Lleno, deja
  de recibir. Conviene guardar en el teléfono, no en el SIM.
- Un solo hilo: "Borrar conversación" borra todo de una vez. El README recomienda hacerlo cada semana.
- Escribir en modo reducido o sin tildes, si el teléfono lo permite: con una tilde
  el SMS del dueño baja a 70 caracteres.
- Algunos básicos muy antiguos no unen SMS en partes: por eso los menús caben en 1 SMS.
- En la puerta de enlace los SMS se acumulan en su app de mensajes (sección 2).

## 15. Textos para el README

**Costo.** OldieChat SMS usa dos líneas con SMS: la de tu teléfono y la de la puerta
de enlace, un Android con OldieChat App abierto. Referencia: Movistar Plan voz Libre,
$8.990 al mes con 500 SMS y sin datos (noviembre de 2026). En prepago sin bolsa, cada
SMS cuesta de $50 a $70. Tener las dos líneas en la misma compañía no baja el costo.
Cada SMS que envías se cobra en tu línea; cada respuesta, en la línea de la puerta de
enlace.

**Cuota.** Revisar dos veces al día y conversar un rato usa unos 400 SMS al mes en cada
línea: 500 alcanzan para un uso normal; un uso intenso necesita 1.000 en cada una. La
llamada perdida para pedir el menú es gratis.

**Puerta de enlace.** Queda en casa, enchufada y con la pantalla encendida: solo
funciona mientras OldieChat está abierto en modo SMS.

**Riesgo.** La puerta de enlace solo atiende a tu número y siempre responde a tu
número. Quien falsifique tu número no puede leer tus chats, pero sí podría enviar
mensajes de WhatsApp a tu nombre.

**Condición de los planes.** Movistar y Claro dicen por escrito que los SMS del plan son
de persona a persona, de terminal a terminal, y prohíben enviarlos con software o
aplicaciones. Entel y WOM piden uso personal habitual. La puerta de enlace es un
teléfono que responde a un solo número y a bajo volumen, pero envía con una
aplicación. Revisa las condiciones de tu plan: el riesgo de que la compañía corte la
línea es tuyo. OldieChat no recomienda compañía.

**Regla de los 14 días.** WhatsApp pide abrir la cuenta en el teléfono principal al
menos cada 14 días; si no, cierra la sesión de los dispositivos vinculados, también la
de la puerta de enlace. Un dispositivo vinculado sin uso por 30 días también se
desconecta. Desde el día 12, OldieChat te lo recuerda en la siguiente respuesta.

(La versión en inglés se escribe al cerrar la versión.)

## Órdenes al motor

Solo estas: chats recientes de personas, chats recientes de grupos, mensajes nuevos
de un chat, enviar mensaje. Además el motor informa sesión cerrada y, para el aviso de
14 días, mensajes propios enviados desde el principal.

## Sin resolver

- Ningún teléfono de prueba tiene a la vez sesión y chip Movistar: el Fame tiene chip
  sin sesión y el Core 2 sesión sin red Movistar.
- Si el segundo plano del principal cuenta para los 14 días.
- El tiempo hasta que el SMS llega al teléfono del dueño (no se midió en la etapa 0).
- Que `su 1001` y `content` funcionen con SELinux Enforcing en el Core 2.
- El consumo de memoria de la puerta de enlace.

## Decisiones del dueño (7 de noviembre de 2026)

1. El Fame se vincula como dispositivo nuevo en el Área 1, etapa 7; no antes.
2. Sin PIN; el riesgo va en el README.
3. Sin prefijo: si el texto empieza con número, se escribe antes el número de la persona.
4. Grupos con `g`, `gn` y `gn texto`; ayuda con `a`. Sin `#` ni `?`.
5. Logo solo en la bienvenida y la ayuda.
6. No se recomienda compañía: el README muestra las condiciones de las cuatro.
7. Caso (b): WhatsApp lo abre el dueño con la tecla de OldieChat.
