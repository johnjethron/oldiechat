#!/usr/bin/env bash
#
# player/build.sh - compila Player.java a player.jar (classes.dex para Dalvik).
# Usa un contenedor con JDK y d8 (r8) de Google; no necesita el SDK de Android.
#
# Uso: player/build.sh <salida.jar>

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$(cd "$(dirname "${1:?uso: build.sh <salida.jar>}")" && pwd)/$(basename "$1")"
# shellcheck source=../versions.env
source "${HERE}/../versions.env"
CACHE="${HERE}/../work/cache"

mkdir -p "${CACHE}"
R8="${CACHE}/r8-${R8_VERSION}.jar"
[[ -s "${R8}" ]] || curl -fsSL "https://dl.google.com/android/maven2/com/android/tools/r8/${R8_VERSION}/r8-${R8_VERSION}.jar" -o "${R8}"
echo "${R8_SHA256}  ${R8}" | sha256sum -c --quiet - || { echo "checksum de r8 incorrecto" >&2; exit 1; }

docker run --rm --user "$(id -u):$(id -g)" \
  -v "${HERE}:/player:ro" -v "${CACHE}:/cache" -v "$(dirname "${OUT}"):/out" \
  "${JDK_IMAGE}" bash -euo pipefail -c "
    T=\$(mktemp -d)
    javac --release 8 -d \$T/stubs \$(find /player/stubs -name '*.java')
    javac --release 8 -cp \$T/stubs -d \$T/classes \$(find /player/src -name '*.java')
    java -cp /cache/r8-${R8_VERSION}.jar com.android.tools.r8.D8 --release --min-api 16 \
      --lib \$T/stubs --output /out/$(basename "${OUT}") \$(find \$T/classes -name '*.class')
  "
ls -l "${OUT}"
