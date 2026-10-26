# OldieChat

Al empezar, lee `docs/ESTADO.md` (qué está hecho y para qué sirve cada carpeta).

Proyecto: OldieChat (github.com/johnjethron/oldiechat). Cliente no oficial compatible con WhatsApp para teléfonos antiguos y dumbphones. Versión publicada: 0.2.1 (terminal, basada en nchat y whatsmeow).

Usuario: la persona que quiere dejar el smartphone y prueba un dumbphone, o que quiere usar un Android 4G guardado como teléfono simple. Un teléfono soportado tiene que llamar y enviar SMS en las redes actuales. Plataformas: Android (con teclas y Android 4G reutilizados), app nativa; KaiOS 2.5, plataforma importante a explorar con un Nokia 6300 4G; dumbphones de sistema cerrado: puente SMS, con mensajes que se piden. El Fame es el banco de pruebas donde se construye el motor. Toda interfaz nueva debe poder usarse solo con teclado físico (teclado numérico, cruceta y teclas de función).

Teléfonos de prueba:
- Samsung Galaxy Fame GT-S6810L: Android 4.1.2, kernel 3.0.15, ARMv7 Cortex-A9, 512 MB de RAM, con root (SuperSU), conectado por USB con ADB. Usa TermOne Plus como terminal y el comando /system/bin/wsp para abrir OldieChat.

Equipo de compilación: Linux Mint (base Ubuntu 24.04) en un MacBook Air, x86_64, con Docker, qemu-user-static, ADB, gh y Claude Code.

Principios del proyecto, en orden de importancia:
1. OldieChat existe para que nadie tenga que volver al smartphone por falta de WhatsApp. Solo se soportan teléfonos que llaman y envían SMS en las redes actuales. Reutilizar teléfonos antiguos es bienvenido cuando cumplen eso.
2. whatsmeow siempre se mantiene en su versión más reciente. Nosotros adaptamos Go con parches propios para que siga funcionando en kernels antiguos. No se depende de otro dispositivo para que el teléfono funcione.
3. Liviandad: el objetivo son teléfonos con 256 a 512 MB de RAM.
4. Simple, intuitivo y ordenado: minimalismo digital, también en el código.
5. OldieChat solo funciona mientras está abierto. Sin procesos en segundo plano ni notificaciones. Al abrirlo, sincroniza lo pendiente.

Forma de trabajar:
- Tengo TDA: avanza en pasos cortos y dime en una frase qué haces en cada uno.
- Trabaja solo la etapa que te pido. Al terminarla, muéstrame el resultado y espera mi visto bueno antes de seguir.
- Responde en español. Nunca expliques con ejemplos ni metáforas.
- Código minimal: antes de agregar código, revisa si se resuelve quitando algo o con configuración. Cada cambio debe ser lo más pequeño posible y los parches a nchat, cortos y separados. Al terminar cada paso, dime cuántas líneas agregaste y cuántas quitaste.
- No inyectes teclas por ADB en mis conversaciones reales sin avisarme antes.
- Haz commit al terminar cada paso. No subas nada a GitHub; eso lo hago yo.
- Si algo parece no tener solución, dímelo directo antes de seguir intentando.
- Avísame cuando necesites que haga algo en el teléfono.
- Cuando te diga 'terminamos por hoy', actualiza docs/ESTADO.md con el estado exacto (qué está hecho, en qué rama, qué falta compilar o probar, y qué sigue) y haz commit. No compiles.

## Reglas técnicas del repositorio

- Parches a nchat en `nchat/patches/`, uno por tema y numerados sin huecos; parches a Go en `go/patches/`.
- Las opciones nuevas de nchat van apagadas por defecto en el parche y se encienden en `phone/config/`.
- Antes de borrar algo grande o cambiar la estructura, muestra un inventario y espera aprobación.
- Al cerrar una versión: `VERSION`, `CHANGELOG.md`, README (español e inglés), `docs/ESTADO.md` y `scripts/phone-test.sh --sound` en el teléfono.
