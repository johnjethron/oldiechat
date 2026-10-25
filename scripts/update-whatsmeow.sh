#!/usr/bin/env bash
#
# update-whatsmeow.sh - actualiza whatsmeow en la terminal y en el motor.
#
#   scripts/update-whatsmeow.sh [commit]    sin commit: el último de whatsmeow
#
# Fija el commit en versions.env y ejecuta scripts/vendor-go.sh.

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
commit="${1:-$(git ls-remote https://github.com/tulir/whatsmeow refs/heads/main | cut -c1-7)}"
sed -i "s/^WHATSMEOW_COMMIT=.*/WHATSMEOW_COMMIT=${commit}/" "${HERE}/versions.env"
exec "${HERE}/scripts/vendor-go.sh"
