#!/usr/bin/env bash
#
# vendor-go.sh - guarda en el repositorio las dependencias Go (go mod vendor),
# para poder compilar aunque algún módulo desaparezca de internet.
#
#   nchat/vendor/   dependencias de la parte Go de nchat (con parches)
#   engine/vendor/  dependencias del motor
#
# Ambas con whatsmeow en WHATSMEOW_COMMIT (versions.env).
#
# Se ejecuta en el contenedor de compilación, con el Go fijado. Necesita
# work/nchat (ejecuta antes ./build.sh) y acceso a internet.

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../versions.env
source "${HERE}/versions.env"
IMAGE="${IMAGE:-oldiechat-builder}"
SRC="${HERE}/work/nchat"

[[ -d "${SRC}/.git" ]] || { echo "falta work/nchat: ejecuta antes ./build.sh" >&2; exit 1; }

echo "==> nchat @ ${NCHAT_COMMIT:0:7}"
git -C "${SRC}" checkout --quiet --force "${NCHAT_COMMIT}"
git -C "${SRC}" clean -qfdx lib/wmchat/go

# whatsmeow con el script de nchat (copia, parche de nchat, fecha, go mod tidy)
echo "==> whatsmeow @ ${WHATSMEOW_COMMIT}, parches y go mod vendor"
docker run --rm --platform linux/arm/v7 --user "$(id -u):$(id -g)" \
  -e HOME=/work/cache -e GOCACHE=/work/cache/go-build -e GOPATH=/work/cache/go \
  -e GOFLAGS=-modcacherw -e GOTOOLCHAIN=local -e W="${WHATSMEOW_COMMIT}" \
  -v "${HERE}/work:/work" -v "${HERE}/engine:/engine" \
  -v "${HERE}/nchat/patches:/patches:ro" "${IMAGE}" sh -euc '
    cd /work/nchat && utils/whatsmeow-update "$W"
    ! find lib/wmchat/go/ext -name "*.rej" | grep .
    for p in /patches/*.patch; do git apply "$p"; done
    cd lib/wmchat/go && go mod vendor
    cd /engine && go get "go.mau.fi/whatsmeow@$W" && go mod tidy && go mod vendor
  '

rm -rf "${HERE}/nchat/vendor"
mv "${SRC}/lib/wmchat/go/vendor" "${HERE}/nchat/vendor"
du -sh "${HERE}/nchat/vendor" "${HERE}/engine/vendor"
