#!/usr/bin/env bash
#
# build.sh - compila OldieChat terminal: nchat (solo WhatsApp) como binario
# estático musl para ARMv7, más el conversor y el reproductor de audio.
#
# Requisitos en el host (x86_64): docker, qemu-user-static, binfmt-support, curl.
# Versiones exactas: versions.env. Parches: nchat/patches/ y go/patches/.
# Dependencias Go: nchat/vendor/ y engine/vendor/.
# Resultado: out/oldiechat-terminal-<versión>-armv7/            (paquete)
#            out/oldiechat-terminal-<versión>-armv7.tar.gz       (para Releases)
#            out/oldiechat-terminal-<versión>-source.tar.gz      (código fuente completo)
#            out/engine/oldiechat-engine-armv7                   (motor, para pruebas)
#
# Uso: ./build.sh            compila
#      ./build.sh shell      abre una shell en el contenedor armv7

set -euo pipefail

VERSION="$(cat "$(dirname "$0")/VERSION")"
# shellcheck source=versions.env
source "$(dirname "$0")/versions.env"
IMAGE="${IMAGE:-oldiechat-builder}"
PLATFORM="linux/arm/v7"
JOBS="${JOBS:-$(nproc)}"

# Terminales que se incluyen en terminfo/ (TermOne Plus ofrece vt100, screen,
# linux, screen-256color y xterm; adb shell usa vt100 o dumb).
TERMS="vt100 vt102 ansi linux screen screen-256color xterm xterm-color xterm-256color dumb"

HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${HERE}/work"
SRC="${WORK}/nchat"
NAME="oldiechat-terminal-${VERSION}-armv7"
OUT="${HERE}/out/${NAME}"

log() { printf '\n==> %s\n' "$*"; }

check_host() {
  command -v docker >/dev/null || { echo "Falta docker" >&2; exit 1; }
  if [[ ! -e /proc/sys/fs/binfmt_misc/qemu-arm ]]; then
    echo "binfmt para ARM no registrado: instala qemu-user-static y binfmt-support" >&2
    exit 1
  fi
}

fetch_source() {
  log "Código fuente nchat @ ${NCHAT_COMMIT:0:7}"
  if [[ ! -d "${SRC}/.git" ]]; then
    mkdir -p "${WORK}"
    git clone "${NCHAT_REPO}" "${SRC}"
  fi
  git -C "${SRC}" fetch --quiet origin "${NCHAT_COMMIT}" 2>/dev/null || true
  git -C "${SRC}" checkout --quiet --force "${NCHAT_COMMIT}"

  local p
  for p in "${HERE}"/nchat/patches/*.patch; do
    [[ -e "${p}" ]] || continue
    log "Aplicando $(basename "${p}")"
    git -C "${SRC}" apply "${p}"
  done

  # dependencias Go de nchat guardadas en el repositorio (scripts/vendor-go.sh)
  if [[ -d "${HERE}/nchat/vendor" ]]; then
    rm -rf "${SRC}/lib/wmchat/go/vendor"
    cp -r "${HERE}/nchat/vendor" "${SRC}/lib/wmchat/go/vendor"
  fi
}

build_image() {
  log "Imagen Docker ${IMAGE} (${PLATFORM})"
  local ctx="${WORK}/docker"
  rm -rf "${ctx}"; mkdir -p "${ctx}"
  cp "${HERE}/Dockerfile.armv7" "${ctx}/Dockerfile"
  mkdir -p "${ctx}/go-patches"
  cp "${HERE}"/go/patches/*.patch "${ctx}/go-patches/" 2>/dev/null || true
  docker build --platform "${PLATFORM}" -t "${IMAGE}" \
    --build-arg ALPINE_IMAGE="${ALPINE_IMAGE}" \
    --build-arg GO_VERSION="${GO_VERSION}" --build-arg GO_SHA256="${GO_SHA256}" \
    --build-arg OPUS_VERSION="${OPUS_VERSION}" --build-arg OPUS_SHA256="${OPUS_SHA256}" \
    "${ctx}"
}

run_in_container() {
  mkdir -p "${WORK}/cache"
  docker run --rm -i $([[ -t 0 ]] && echo -t) --platform "${PLATFORM}" \
    --user "$(id -u):$(id -g)" \
    -e HOME=/work/cache -e GOCACHE=/work/cache/go-build -e GOPATH=/work/cache/go \
    -e GOFLAGS="-mod=vendor -modcacherw" -e GOPROXY=off -e GOTOOLCHAIN=local \
    -e JOBS="${JOBS}" -e TERMS="${TERMS}" -e NAME="${NAME}" \
    -v "${WORK}:/work" -v "${HERE}/out:/out" -v "${HERE}/phone:/phone:ro" \
    -v "${HERE}/engine:/engine:ro" -v "${HERE}/LICENSE:/LICENSE:ro" \
    -w /work "${IMAGE}" "$@"
}

compile() {
  log "Compilando dentro del contenedor (lento: corre sobre qemu)"
  mkdir -p "${HERE}/out"
  run_in_container bash -euo pipefail -c '
    B=/work/build
    rm -rf "$B"
    # -static -no-pie: binario ELF estático clásico, sin cargador dinámico.
    cmake -S /work/nchat -B "$B" -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DHAS_STATIC_EXTLIBS=ON \
      -DHAS_MUSL_GO_PATCHED=ON \
      -DHAS_WHATSAPP=ON \
      -DHAS_TELEGRAM=OFF \
      -DHAS_SIGNAL=OFF \
      -DHAS_DUMMY=OFF \
      -DHAS_COREDUMP=OFF \
      -DHAS_MULTIPROTOCOL=OFF \
      -DCMAKE_EXE_LINKER_FLAGS="-static -no-pie"
    grep -q "^HAS_WHATSAPP:BOOL=ON" "$B/CMakeCache.txt"
    cmake --build "$B" -j "$JOBS"

    O="/out/$NAME"
    rm -rf "$O"; mkdir -p "$O/bin" "$O/lib" "$O/terminfo" "$O/config" "$O/licenses"
    cp "$B/bin/nchat" "$O/bin/nchat"
    strip --strip-all "$O/bin/nchat"

    # motor (engine/): conversor Opus -> WAV para el paquete y el motor completo
    # para scripts/phone-test.sh (libopus estático de la imagen)
    cd /engine
    export CGO_ENABLED=1 CGO_CFLAGS=-I/usr/local/include CGO_LDFLAGS=-L/usr/local/lib
    go build -trimpath -ldflags "-s -w -extldflags -static" -o "$O/bin/oldiechat-audio" ./cmd/oldiechat-audio
    mkdir -p /out/engine
    go build -trimpath -ldflags "-s -w -extldflags -static" -o /out/engine/oldiechat-engine-armv7 ./cmd/oldiechat-engine
    cd /work

    for t in $TERMS; do
      f=$(find /usr/share/terminfo /etc/terminfo -name "$t" -type f 2>/dev/null | head -1)
      [ -n "$f" ] || { echo "terminfo no encontrado: $t" >&2; exit 1; }
      d="$O/terminfo/$(basename "$(dirname "$f")")"
      mkdir -p "$d"; cp "$f" "$d/"
    done

    # zonas horarias: Android usa un formato propio que musl y Go no leen
    cp -r /usr/share/zoneinfo "$O/zoneinfo"
    rm -rf "$O/zoneinfo/posix" "$O/zoneinfo/right"

    cp /phone/oldiechat.sh /phone/audio.sh /phone/install.sh /phone/oldiechat.png "$O/"
    cp /phone/config/* "$O/config/"
    mkdir -p "$O/fonts"; cp /phone/fonts/* "$O/fonts/"

    # licencias: el binario combinado se distribuye bajo GPL v3 (ver nchat)
    cp /LICENSE "$O/licenses/LICENSE.oldiechat"
    cp /work/nchat/LICENSE "$O/licenses/LICENSE.nchat"
    cp /work/nchat/LICENSE.GPL-3.0 "$O/licenses/LICENSE.GPL-3.0"
    cp /work/nchat/lib/wmchat/go/ext/whatsmeow/LICENSE "$O/licenses/LICENSE.whatsmeow"
    cp "$B/THIRD_PARTY_LICENSES" "$O/licenses/THIRD_PARTY_LICENSES"
    cp /usr/local/share/doc/opus/COPYING "$O/licenses/LICENSE.opus"
    cp /usr/local/go/LICENSE "$O/licenses/LICENSE.go"
    cp /phone/licenses/* "$O/licenses/"

    chmod -R u=rwX,go=rX "$O"
    chmod 755 "$O/oldiechat.sh" "$O/audio.sh" "$O/install.sh" "$O/bin/nchat" "$O/bin/oldiechat-audio"
  '
}

build_player() {
  log "Reproductor (player.jar)"
  "${HERE}/player/build.sh" "${OUT}/lib/player.jar"
}

package() {
  log "Verificando y empaquetando"
  local bin info
  for bin in "${OUT}/bin/nchat" "${OUT}/bin/oldiechat-audio"; do
    info="$(file "${bin}")"
    grep -q "ARM" <<<"${info}" || { echo "No es ARM: ${bin}" >&2; exit 1; }
    grep -q "statically linked" <<<"${info}" || { echo "No es estático: ${bin}" >&2; exit 1; }
    if readelf -l "${bin}" | grep -q INTERP; then
      echo "Tiene intérprete dinámico: ${bin}" >&2; exit 1
    fi
  done
  [[ -s "${OUT}/lib/player.jar" ]] || { echo "Falta player.jar" >&2; exit 1; }
  local lic
  for lic in LICENSE.oldiechat LICENSE.nchat LICENSE.whatsmeow LICENSE.GPL-3.0 THIRD_PARTY_LICENSES \
             LICENSE.opus LICENSE.go LICENSE.musl LICENSE.gcc-runtime-exception OFL.txt; do
    [[ -s "${OUT}/licenses/${lic}" ]] || { echo "Falta la licencia ${lic}" >&2; exit 1; }
  done
  if command -v qemu-arm-static >/dev/null; then
    qemu-arm-static "${OUT}/bin/nchat" --version | head -1
  fi
  cp "${HERE}/README.md" "${HERE}/README.en.md" "${OUT}/"
  tar -C "${HERE}/out" -czf "${OUT}.tar.gz" "${NAME}"
  (cd "${HERE}/out" && sha256sum "${NAME}.tar.gz" > "${NAME}.tar.gz.sha256")
  ls -lh "${OUT}.tar.gz"
  cat "${OUT}.tar.gz.sha256"
}

# Código fuente completo de la versión (GPL v3 y respaldo): este repositorio más
# nchat en el commit fijado, con parches y dependencias Go ya incluidas.
source_package() {
  log "Paquete de código fuente"
  local name="oldiechat-terminal-${VERSION}-source"
  local tmp="${WORK}/source/${name}"
  rm -rf "${WORK}/source"; mkdir -p "${tmp}"
  tar -C "${HERE}" --exclude=./work --exclude=./out --exclude=./.git --exclude=./build.log -cf - . | tar -C "${tmp}" -xf -
  tar -C "${WORK}" --exclude=./nchat/.git -cf - nchat | tar -C "${tmp}" -xf -
  mv "${tmp}/nchat" "${tmp}/nchat-${NCHAT_COMMIT:0:7}-patched"
  tar -C "${WORK}/source" -czf "${HERE}/out/${name}.tar.gz" "${name}"
  (cd "${HERE}/out" && sha256sum "${name}.tar.gz" > "${name}.tar.gz.sha256")
  ls -lh "${HERE}/out/${name}.tar.gz"
}

main() {
  check_host
  fetch_source
  build_image
  if [[ "${1:-}" == "shell" ]]; then
    run_in_container bash
    exit 0
  fi
  compile
  build_player
  package
  source_package
}

main "$@"
