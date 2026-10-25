#!/usr/bin/env bash
#
# check-go-version.sh - revisa si nchat, whatsmeow o las dependencias del motor
# exigen un Go más nuevo que el fijado en versions.env.
#
# Revisa dos cosas:
#   1. Lo fijado: el commit de nchat en work/nchat (después de ./build.sh) y
#      engine/vendor/modules.txt.
#   2. Lo último publicado: go.mod de whatsmeow (rama main) y de nchat (master).
#
# Código de salida: 0 si todo cabe en el Go fijado, 1 si algo exige uno más
# nuevo (ver MAINTAINING.md, "whatsmeow exige un Go más nuevo").

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../versions.env
source "${HERE}/versions.env"

newer=0

# imprime la versión de Go que pide un go.mod (directiva "go")
go_directive() {
  awk '$1 == "go" { print $2; exit }'
}

compare() {
  local what="$1" need="$2"
  if [[ -z "${need}" ]]; then
    printf '  ?    %-48s (sin directiva go)\n' "${what}"
    return
  fi
  if [[ "$(printf '%s\n%s\n' "${need}" "${GO_VERSION}" | sort -V | tail -1)" == "${GO_VERSION}" ]]; then
    printf '  ok   %-48s go %s\n' "${what}" "${need}"
  else
    printf '  NUEVO %-47s go %s > %s\n' "${what}" "${need}" "${GO_VERSION}"
    newer=1
  fi
}

echo "Go fijado: ${GO_VERSION}"
echo
echo "Fijado en el repositorio:"
NCHAT="${HERE}/work/nchat"
if [[ -d "${NCHAT}/lib/wmchat/go" ]]; then
  compare "nchat ${NCHAT_COMMIT:0:7} lib/wmchat/go" "$(go_directive < "${NCHAT}/lib/wmchat/go/go.mod")"
  compare "whatsmeow incluido en nchat" "$(go_directive < "${NCHAT}/lib/wmchat/go/ext/whatsmeow/go.mod")"
else
  echo "  (falta work/nchat: ejecuta antes ./build.sh)"
fi
compare "engine/go.mod" "$(go_directive < "${HERE}/engine/go.mod")"
if [[ -f "${HERE}/engine/vendor/modules.txt" ]]; then
  # cada módulo vendorizado registra "## explicit; go 1.xx"
  while read -r mod ver; do
    compare "engine: ${mod}" "${ver}"
  done < <(awk '/^# / { mod = $2 } /^## / { for (i = 1; i <= NF; i++) if ($i == "go") print mod, $(i+1) }' \
             "${HERE}/engine/vendor/modules.txt" | sort -u)
fi

echo
echo "Último publicado:"
fetch() { curl -fsSL --max-time 20 "$1" 2>/dev/null || true; }
compare "whatsmeow main" "$(fetch https://raw.githubusercontent.com/tulir/whatsmeow/main/go.mod | go_directive)"
compare "nchat master lib/wmchat/go" "$(fetch https://raw.githubusercontent.com/d99kris/nchat/master/lib/wmchat/go/go.mod | go_directive)"
compare "nchat master whatsmeow incluido" \
  "$(fetch https://raw.githubusercontent.com/d99kris/nchat/master/lib/wmchat/go/ext/whatsmeow/go.mod | go_directive)"

echo
if [[ ${newer} -eq 0 ]]; then
  echo "Todo cabe en Go ${GO_VERSION}."
else
  echo "Algo exige un Go más nuevo que ${GO_VERSION}: ver MAINTAINING.md."
fi
exit ${newer}
