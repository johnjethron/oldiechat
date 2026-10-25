#!/usr/bin/env bash
#
# phone-test.sh - prueba la compilación en el teléfono por ADB antes de publicar.
#
# Comprueba, como root, en el teléfono conectado:
#   - kernel y procesador
#   - que nchat arranque (oldiechat.sh --version)
#   - la conversión de audio (oldiechat-audio con tests/data/tono-3s.oga)
#   - con el motor (oldiechat-engine selftest): DNS con servidores propios,
#     HTTPS hacia el servidor de mensajería con certificados propios y zona horaria
#   - opcional (--sound): que el reproductor suene (tono de 3 segundos)
#
# Usa el paquete instalado en /data/local/tmp/oldiechat (ejecuta antes
# install.sh) y out/engine/oldiechat-engine-armv7, que se copia solo durante la
# prueba. Código de salida 0 si todo pasa.
#
# Uso: scripts/phone-test.sh [--sound]

set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
DEST="/data/local/tmp/oldiechat"
T="/data/local/tmp/oldiechat-test"
ENGINE="${HERE}/out/engine/oldiechat-engine-armv7"
CA="${CA_BUNDLE:-/etc/ssl/certs/ca-certificates.crt}"
SOUND=0
[[ "${1:-}" == "--sound" ]] && SOUND=1

fails=0
pass() { printf '  ok     %s\n' "$*"; }
fail() { printf '  FALLA  %s\n' "$*"; fails=$((fails + 1)); }

# adb shell de Android 4.x no devuelve el código de salida
root() {
  local out
  out="$(adb shell "su -c '$1'; echo __rc=\$?" | tr -d '\r')"
  printf '%s\n' "${out}" | grep -v '^__rc='
  grep -q '^__rc=0$' <<<"${out}"
}

echo "== Teléfono"
adb get-state >/dev/null 2>&1 || { echo "no hay teléfono conectado"; exit 1; }
root "id" | grep -q 'uid=0' || { echo "su no da root"; exit 1; }
echo "  kernel: $(adb shell cat /proc/version | tr -d '\r' | cut -d' ' -f1-3)"
echo "  cpu:    $(adb shell cat /proc/cpuinfo | tr -d '\r' | grep -m1 -E '^Processor|^model name' | cut -d: -f2-)"
echo "  android: $(adb shell getprop ro.build.version.release | tr -d '\r')"

echo "== Programa instalado"
if v="$(root "${DEST}/oldiechat.sh --version" | grep -m1 '^nchat')"; then
  pass "nchat arranca: ${v}"
else
  fail "nchat no arranca (¿falta install.sh?)"
fi

adb shell "rm -r ${T} 2>/dev/null; mkdir ${T}" >/dev/null
adb push "${HERE}/tests/data/tono-3s.oga" "${T}/tono.oga" >/dev/null
if root "${DEST}/bin/oldiechat-audio convert ${T}/tono.oga ${T}/tono.wav" >/dev/null &&
   [[ "$(adb shell "ls -l ${T}/tono.wav" | tr -s ' ' | cut -d' ' -f4)" == "96044" ]]; then
  pass "conversión Opus -> WAV (3 s, 16 kHz)"
else
  fail "conversión Opus -> WAV"
fi

echo "== Motor (selftest)"
if [[ -f "${ENGINE}" ]]; then
  adb push "${ENGINE}" "${T}/oldiechat-engine" >/dev/null
  adb push "${CA}" "${T}/certs.pem" >/dev/null
  tzname="$(adb shell getprop persist.sys.timezone | tr -d '\r')"
  out="$(root "chmod 755 ${T}/oldiechat-engine; ${T}/oldiechat-engine selftest --certs ${T}/certs.pem --tz ${tzname:-UTC} 2>&1")"
  rc=$?
  while read -r line; do
    case "${line}" in
      ok\ *) pass "${line#ok }" ;;
      FALLA*) fail "${line#FALLA }" ;;
      ?*) echo "         ${line}" ;;
    esac
  done <<<"${out}"
  [[ ${rc} -eq 0 ]] || [[ "${out}" == *FALLA* ]] || fail "el motor terminó con error"
else
  fail "falta ${ENGINE} (ejecuta antes ./build.sh)"
fi

if [[ ${SOUND} -eq 1 ]]; then
  echo "== Sonido"
  adb logcat -c
  root "CLASSPATH=${DEST}/lib/player.jar app_process /system/bin cl.oldiechat.player.Player ${T}/tono.wav" >/dev/null
  # en una variable: con pipefail, grep -q cortaría la tubería y daría falso error
  log="$(adb logcat -d | tr -d '\r')"
  if grep -q 'createTrack' <<<"${log}"; then
    pass "el reproductor abrió una pista de audio (debería haber sonado un tono)"
  else
    fail "el reproductor no abrió una pista de audio"
  fi
fi

adb shell "su -c 'rm -r ${T}'" >/dev/null 2>&1
echo
if [[ ${fails} -eq 0 ]]; then
  echo "Todo pasó."
else
  echo "${fails} prueba(s) fallaron."
fi
exit $((fails > 0))
