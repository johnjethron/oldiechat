#!/usr/bin/env bash
#
# glyphs.sh - genera config/glyphs.txt a partir de las fuentes de un teléfono
# conectado por ADB.
#
# Copia /system/fonts y los XML de fuentes del teléfono a work/fonts, descarga los
# datos de Unicode 6.0 (los que usa Android 4.1) y ejecuta tools/glyphs.py dentro
# del contenedor armv7 de build.sh. Las fuentes no se guardan en el repositorio.
#
# Uso: tools/glyphs.sh     (después de ./build.sh, que crea la imagen)

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${IMAGE:-oldiechat-builder}"
WORK="${HERE}/work"
FONTS="${WORK}/fonts"
UCD="${WORK}/unicode-6.0"

command -v adb >/dev/null || { echo "Falta adb" >&2; exit 1; }

echo "==> Copiando fuentes del teléfono"
rm -rf "${FONTS}"; mkdir -p "${FONTS}"
adb pull /system/fonts "${FONTS}/" >/dev/null
[[ -d "${FONTS}/fonts" ]] && { mv "${FONTS}"/fonts/* "${FONTS}/"; rmdir "${FONTS}/fonts"; }
for x in system_fonts.xml fallback_fonts.xml; do
  adb pull "/system/etc/${x}" "${FONTS}/${x}" >/dev/null 2>&1 || true
done
ls "${FONTS}" | wc -l | xargs echo "archivos:"

echo "==> Datos de Unicode 6.0"
mkdir -p "${UCD}"
for f in UnicodeData.txt EastAsianWidth.txt; do
  [[ -s "${UCD}/${f}" ]] || curl -fsSL "https://www.unicode.org/Public/6.0.0/ucd/${f}" -o "${UCD}/${f}"
done

echo "==> Generando config/glyphs.txt"
docker run --rm --platform linux/arm/v7 --user "$(id -u):$(id -g)" \
  -v "${WORK}:/work" -v "${HERE}/tools:/tools:ro" -v "${HERE}/config:/config" \
  "${IMAGE}" python3 -I /tools/glyphs.py /work/fonts /work/unicode-6.0 /config/glyphs.txt
