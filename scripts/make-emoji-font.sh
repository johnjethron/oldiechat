#!/usr/bin/env bash
#
# make-emoji-font.sh - genera phone/fonts/NotoEmoji-OldieChat.ttf: Noto Emoji
# monocroma (versión de versions.env) como fuente estática de grosor normal, sin
# las tablas que Android 4.x no usa (variaciones, sustituciones, métricas
# verticales). Pesa unos 850 KB. Necesita python3 con fontTools.
#
# Uso: scripts/make-emoji-font.sh

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../versions.env
source "${HERE}/versions.env"
BASE="https://raw.githubusercontent.com/google/fonts/${NOTO_EMOJI_COMMIT}/ofl/notoemoji"
TMP="${HERE}/work/emoji"
OUT="${HERE}/phone/fonts"

mkdir -p "${TMP}" "${OUT}"
curl -fsSL "${BASE}/NotoEmoji%5Bwght%5D.ttf" -o "${TMP}/NotoEmoji-var.ttf"
echo "${NOTO_EMOJI_SHA256}  ${TMP}/NotoEmoji-var.ttf" | sha256sum -c --quiet -
curl -fsSL "${BASE}/OFL.txt" -o "${HERE}/phone/licenses/OFL.txt"

python3 -I - "${TMP}/NotoEmoji-var.ttf" "${OUT}/NotoEmoji-OldieChat.ttf" <<'PY'
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
font = instancer.instantiateVariableFont(TTFont(sys.argv[1]), {"wght": 400})
for table in ("GSUB", "STAT", "vhea", "vmtx"):
    if table in font:
        del font[table]
font.save(sys.argv[2])
PY
ls -l "${OUT}"
