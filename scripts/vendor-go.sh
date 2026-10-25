#!/usr/bin/env bash
#
# vendor-go.sh - guarda en el repositorio las dependencias Go (go mod vendor),
# para poder compilar aunque algún módulo desaparezca de internet.
#
#   third_party/wmchat-vendor/  dependencias de la parte Go de nchat (con parches)
#   engine/vendor/              dependencias del motor
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

echo "==> nchat @ ${NCHAT_COMMIT:0:7} con parches"
git -C "${SRC}" checkout --quiet --force "${NCHAT_COMMIT}"
git -C "${SRC}" clean -qfdx lib/wmchat/go
for p in "${HERE}"/patches/*.patch; do
  git -C "${SRC}" apply "${p}"
done

echo "==> go mod vendor"
docker run --rm --platform linux/arm/v7 --user "$(id -u):$(id -g)" \
  -e HOME=/work/cache -e GOCACHE=/work/cache/go-build -e GOPATH=/work/cache/go \
  -e GOFLAGS=-modcacherw -e GOTOOLCHAIN=local \
  -v "${HERE}/work:/work" -v "${HERE}/engine:/engine" "${IMAGE}" sh -euc '
    cd /work/nchat/lib/wmchat/go && go mod vendor
    cd /engine && go mod vendor
  '

rm -rf "${HERE}/third_party/wmchat-vendor"
mkdir -p "${HERE}/third_party"
mv "${SRC}/lib/wmchat/go/vendor" "${HERE}/third_party/wmchat-vendor"
du -sh "${HERE}/third_party/wmchat-vendor" "${HERE}/engine/vendor"
