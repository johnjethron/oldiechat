#!/usr/bin/env bash
#
# make-icon.sh - genera el ícono phone/oldiechat.png (192x192) desde
# phone/oldiechat-logo.svg, con rsvg-convert en un contenedor Alpine.
# Necesita internet (descarga rsvg-convert).

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
docker run --rm --platform linux/amd64 -e U="$(id -u):$(id -g)" -v "${HERE}/phone:/p" alpine:3.24 sh -euc '
  apk add -q rsvg-convert
  rsvg-convert -w 192 -h 192 /p/oldiechat-logo.svg -o /p/oldiechat.png
  chown "$U" /p/oldiechat.png
'
