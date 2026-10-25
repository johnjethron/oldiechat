#!/usr/bin/env bash
#
# build.sh - compila OldieChat terminal: nchat (solo WhatsApp) como binario
# estático musl para ARMv7, más el conversor y el reproductor de audio.
#
# Requisitos en el host (x86_64): docker, qemu-user-static, binfmt-support, curl.
# Resultado: out/oldiechat-terminal-<versión>-armv7/      (paquete)
#            out/oldiechat-terminal-<versión>-armv7.tar.gz (para Releases)
#
# Uso: ./build.sh            compila
#      ./build.sh shell      abre una shell en el contenedor armv7

set -euo pipefail

VERSION="$(cat "$(dirname "$0")/VERSION")"
NCHAT_REPO="${NCHAT_REPO:-https://github.com/d99kris/nchat}"
NCHAT_COMMIT="${NCHAT_COMMIT:-91908dfab06356584cc594cd589a33d4a5dc19b3}"
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
  for p in "${HERE}"/patches/*.patch; do
    [[ -e "${p}" ]] || continue
    log "Aplicando $(basename "${p}")"
    git -C "${SRC}" apply "${p}"
  done
}

build_image() {
  log "Imagen Docker ${IMAGE} (${PLATFORM})"
  local ctx="${WORK}/docker"
  rm -rf "${ctx}"; mkdir -p "${ctx}"
  cp "${HERE}/Dockerfile.armv7" "${ctx}/Dockerfile"
  cp "${SRC}/utils/dist/patches/go-pr69325-musl-argv.patch" "${ctx}/"
  docker build --platform "${PLATFORM}" -t "${IMAGE}" "${ctx}"
}

run_in_container() {
  mkdir -p "${WORK}/cache"
  docker run --rm -i $([[ -t 0 ]] && echo -t) --platform "${PLATFORM}" \
    --user "$(id -u):$(id -g)" \
    -e HOME=/work/cache -e GOCACHE=/work/cache/go-build -e GOPATH=/work/cache/go \
    -e GOFLAGS=-modcacherw -e JOBS="${JOBS}" -e TERMS="${TERMS}" -e NAME="${NAME}" \
    -v "${WORK}:/work" -v "${HERE}/out:/out" -v "${HERE}/files:/files:ro" \
    -v "${HERE}/config:/config:ro" -v "${HERE}/audio:/audio:ro" -v "${HERE}/LICENSE:/LICENSE:ro" \
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
      -DCMAKE_EXE_LINKER_FLAGS="-static -no-pie"
    grep -q "^HAS_WHATSAPP:BOOL=ON" "$B/CMakeCache.txt"
    cmake --build "$B" -j "$JOBS"

    O="/out/$NAME"
    rm -rf "$O"; mkdir -p "$O/bin" "$O/lib" "$O/terminfo" "$O/config" "$O/licenses"
    cp "$B/bin/nchat" "$O/bin/nchat"
    strip --strip-all "$O/bin/nchat"

    # conversor Ogg Opus -> WAV (libopus estático de la imagen)
    cd /audio
    CGO_ENABLED=1 CGO_CFLAGS=-I/usr/local/include CGO_LDFLAGS=-L/usr/local/lib \
      go build -trimpath -ldflags "-s -w -extldflags -static" -o "$O/bin/oldiechat-audio" ./cmd/oldiechat-audio
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

    cp /files/oldiechat.sh /files/audio.sh /files/install.sh /files/oldiechat.png "$O/"
    cp /config/*.conf "$O/config/"
    [ ! -f /config/glyphs.txt ] || cp /config/glyphs.txt "$O/config/"

    # licencias: el binario combinado se distribuye bajo GPL v3 (ver nchat)
    cp /LICENSE "$O/licenses/LICENSE.oldiechat"
    cp /work/nchat/LICENSE "$O/licenses/LICENSE.nchat"
    cp /work/nchat/LICENSE.GPL-3.0 "$O/licenses/LICENSE.GPL-3.0"
    cp /work/nchat/lib/wmchat/go/ext/whatsmeow/LICENSE "$O/licenses/LICENSE.whatsmeow"
    cp "$B/THIRD_PARTY_LICENSES" "$O/licenses/THIRD_PARTY_LICENSES"
    cp /usr/local/share/doc/opus/COPYING "$O/licenses/LICENSE.opus"

    chmod -R u=rwX,go=rX "$O"
    chmod 755 "$O/oldiechat.sh" "$O/audio.sh" "$O/install.sh" "$O/bin/nchat" "$O/bin/oldiechat-audio"
    file "$O/bin/nchat" "$O/bin/oldiechat-audio"
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
  [[ -s "${OUT}/licenses/LICENSE.opus" ]] || { echo "Falta la licencia de opus" >&2; exit 1; }
  if command -v qemu-arm-static >/dev/null; then
    qemu-arm-static "${OUT}/bin/nchat" --version | head -1
  fi
  cp "${HERE}/README.md" "${HERE}/README.en.md" "${OUT}/"
  tar -C "${HERE}/out" -czf "${OUT}.tar.gz" "${NAME}"
  (cd "${HERE}/out" && sha256sum "${NAME}.tar.gz" > "${NAME}.tar.gz.sha256")
  ls -lh "${OUT}.tar.gz"
  cat "${OUT}.tar.gz.sha256"
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
}

main "$@"
