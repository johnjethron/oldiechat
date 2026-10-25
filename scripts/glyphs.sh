#!/usr/bin/env bash
#
# glyphs.sh - genera phone/config/glyphs.txt midiendo cómo dibuja la terminal
# cada carácter en el teléfono conectado por ADB (unos 9 minutos en un Cortex-A9).
# Vuelve a ejecutarlo si cambian las fuentes del teléfono (p. ej. al instalar la
# fuente de emoji y reiniciar).
#
# Usa GlyphProbe (player.jar) en el teléfono y scripts/glyphs.py. Ejecuta antes
# ./build.sh.
#
# Uso: scripts/glyphs.sh

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${HERE}/work"
JAR="$(ls -d "${HERE}"/out/oldiechat-terminal-*-armv7/lib/player.jar 2>/dev/null | sort -V | tail -1)"
[[ -n "${JAR}" ]] || { echo "falta player.jar: ejecuta antes ./build.sh" >&2; exit 1; }
command -v adb >/dev/null || { echo "Falta adb" >&2; exit 1; }

echo "==> Midiendo en el teléfono (como root, por la caché de Dalvik)"
adb push "${JAR}" /data/local/tmp/oldiechat-probe.jar >/dev/null
adb shell "su -c 'CLASSPATH=/data/local/tmp/oldiechat-probe.jar app_process /system/bin \
  cl.oldiechat.probe.GlyphProbe A0-FFFF 10000-1FFFF > /data/local/tmp/oldiechat-probe.txt'"
mkdir -p "${WORK}"
adb pull /data/local/tmp/oldiechat-probe.txt "${WORK}/probe.txt" >/dev/null
adb shell "su -c 'rm /data/local/tmp/oldiechat-probe.jar /data/local/tmp/oldiechat-probe.txt'"

echo "==> Generando phone/config/glyphs.txt"
python3 -I "${HERE}/scripts/glyphs.py" "${WORK}/probe.txt" "${HERE}/phone/config/glyphs.txt"
