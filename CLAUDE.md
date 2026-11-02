# OldieChat

Al empezar, lee `docs/ESTADO.md` (qué está hecho y para qué sirve cada carpeta).

Proyecto: OldieChat (github.com/johnjethron/oldiechat). Cliente no oficial compatible con WhatsApp para teléfonos antiguos y dumbphones. Versión publicada: 0.2.2 (terminal, basada en nchat y whatsmeow).

Productos: OldieChat App (Android, app nativa; también hace de puerta de enlace) y OldieChat SMS (cualquier teléfono con SMS, a través de un teléfono con OldieChat App). Toda interfaz nueva debe poder usarse solo con teclado físico (teclado numérico, cruceta y teclas de función).

Usuario: la persona que quiere dejar el smartphone y prueba un dumbphone, o que quiere usar un Android 4G guardado como teléfono simple. Un teléfono soportado tiene que llamar y enviar SMS en las redes actuales.

Teléfonos de prueba (el Fame es el banco de pruebas donde se construye el motor):
- Samsung Galaxy Fame GT-S6810L: Android 4.1.2, kernel 3.0.15, ARMv7 Cortex-A9, 512 MB de RAM, con root (SuperSU), conectado por USB con ADB. Usa TermOne Plus como terminal y el comando /system/bin/wsp para abrir OldieChat. Pantalla rota: se usa solo por ADB. Android 4.1 no trae cp ni chown -R.
- Samsung Galaxy Core 2 SM-G355H: Android 4.4.2, ARMv7, 768 MB de RAM, solo 3G. Llega la primera semana de noviembre de 2026.

Equipo de compilación: Linux Mint (base Ubuntu 24.04) en un MacBook Air, x86_64, con Docker, qemu-user-static, ADB, gh y Claude Code.
Equipo de compilación: PC de escritorio con CachyOS (shell fish). Proyecto en ~/Projects/OldieChat. Compilar con: time ./build.sh > build.log 2>&1. No borrar work/: guarda la caché de Go.

Principios del proyecto, en orden de importancia:
1. Minimalismo digital en todo: uso, código, motor y archivos. Simple, intuitivo y ordenado.
2. OldieChat existe para que nadie tenga que volver al smartphone por falta de WhatsApp. Solo se soportan teléfonos que llaman y envían SMS en las redes actuales. Reutilizar teléfonos antiguos es bienvenido cuando cumplen eso.
3. whatsmeow siempre actualizado; nosotros adaptamos Go para kernels antiguos. OldieChat App no depende de otro dispositivo; OldieChat SMS depende de un teléfono con OldieChat App.
4. Liviandad: teléfonos de 256 a 512 MB de RAM.
5. Solo funciona mientras está abierto: sin segundo plano ni notificaciones. La puerta de enlace funciona mientras OldieChat está abierto en modo SMS. Al abrirlo, sincroniza lo pendiente.

Forma de trabajar:
- Tengo TDA: avanza en pasos cortos y dime en una frase qué haces en cada uno.
- Trabaja solo la etapa que te pido. Al terminarla, muéstrame el resultado y espera mi visto bueno antes de seguir.
- Responde en español. Nunca expliques con ejemplos ni metáforas.
- Código minimal: antes de agregar código, revisa si se resuelve quitando algo o con configuración. Cada cambio debe ser lo más pequeño posible y los parches a nchat, cortos y separados. Al terminar cada paso, dime cuántas líneas agregaste y cuántas quitaste.
- Si te pido una idea nueva o un cambio de dirección, pregúntame si es necesario y si encaja con el minimalismo antes de hacerlo.
- No inyectes teclas por ADB en mis conversaciones reales sin avisarme antes.
- Haz commit al terminar cada paso. No subas nada a GitHub; eso lo hago yo.
- Si algo parece no tener solución, dímelo directo antes de seguir intentando.
- Avísame cuando necesites que haga algo en el teléfono.
- Cuando te diga 'terminamos por hoy', actualiza docs/ESTADO.md con el estado exacto (qué está hecho, en qué rama, qué falta compilar o probar, y qué sigue) y haz commit. No compiles.

Ahorro de uso:
- Cada etapa empieza en una conversación nueva: lee docs/ESTADO.md y la etapa indicada.
- Si el prompt dice "Modelo: Opus" y estás en otro modelo, avísame antes de empezar.
- Al compilar, guarda el log en un archivo y lee solo los errores y las últimas líneas.
- Lee solo los archivos que nombra la etapa; pregunta antes de recorrer el repositorio.
- Respuestas cortas: qué hiciste, líneas agregadas y quitadas, y qué sigue.

## Reglas técnicas del repositorio

- Parches a nchat en `nchat/patches/`, uno por tema y numerados sin huecos; parches a Go en `go/patches/`.
- Las opciones nuevas de nchat van apagadas por defecto en el parche y se encienden en `phone/config/`.
- Antes de borrar algo grande o cambiar la estructura, muestra un inventario y espera aprobación.
- Al cerrar una versión: `VERSION`, `CHANGELOG.md`, README (español e inglés), `docs/ESTADO.md` y `scripts/phone-test.sh --sound` en el teléfono.
