# OldieChat

Al empezar, lee `docs/ESTADO.md` (qué está hecho y para qué sirve cada carpeta).

Proyecto: OldieChat (github.com/johnjethron/oldiechat). Cliente no oficial compatible con WhatsApp para teléfonos antiguos y dumbphones. Versión publicada: 0.2.1 (terminal, basada en nchat y whatsmeow).

Teléfonos de prueba:
- Samsung Galaxy Fame GT-S6810L: Android 4.1.2, kernel 3.0.101, ARMv7 Cortex-A9, 512 MB de RAM, con root (SuperSU), conectado por USB con ADB. Usa TermOne Plus como terminal y el comando /system/bin/wsp para abrir OldieChat.
- Por conseguir: un Android 2.3 con ARMv6 y menos de 300 MB de RAM (Samsung Galaxy Y GT-S5360L o Galaxy Ace GT-S5830), y dumbphones de cada tipo.
- Objetivo en dumbphones: rescatar teléfonos de teclas antiguos, no comprar nuevos. Sin navegador. Los de sistema cerrado llegan por un puente SMS, y los que tienen Java (J2ME) y 3G, por un cliente J2ME con datos.

Equipo de compilación: Linux Mint (base Ubuntu 24.04) en un MacBook Air, x86_64, con Docker, qemu-user-static, ADB, gh y Claude Code.

Principios del proyecto, en orden de importancia:
1. Ningún teléfono antiguo debe quedar sin soporte. La compatibilidad es hacia atrás: distintos Android antiguos, procesadores y dumbphones, no solo el Fame. Las versiones nuevas de Android se soportan solo si no agregan peso ni complejidad.
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

## Reglas técnicas del repositorio

- Parches a nchat en `nchat/patches/`, uno por tema y numerados sin huecos; parches a Go en `go/patches/`.
- Las opciones nuevas de nchat van apagadas por defecto en el parche y se encienden en `phone/config/`.
- Antes de borrar algo grande o cambiar la estructura, muestra un inventario y espera aprobación.
- Al cerrar una versión: `VERSION`, `CHANGELOG.md`, README (español e inglés), `docs/ESTADO.md` y `scripts/phone-test.sh --sound` en el teléfono.
