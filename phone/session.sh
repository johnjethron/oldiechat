#!/usr/bin/env bash
#
# session.sh - respalda en el PC la sesión de WhatsApp de OldieChat o la
# restaura en otro teléfono. OldieChat debe estar cerrado en el teléfono.
#
# Uso: ./session.sh respaldar             (queda en ~/Respaldos/oldiechat/)
#      ./session.sh restaurar <archivo>   (después de ./install.sh)
# ANDROID_SERIAL elige el teléfono si hay más de uno conectado.

set -euo pipefail

H=/data/local/tmp/oldiechat/home
N="${H}/.config/nchat"
T=/data/local/tmp/oldiechat-session
# copia recursiva con cat (Android 4.x no trae cp ni chown -R): c origen destino dueño
F='c() { mkdir $2 2>/dev/null; chown $3 $2; chmod 700 $2; for f in $1/*; do n=$2/${f##*/}; case ${f##*/} in tmp) continue;; esac; if [ -d $f ]; then c $f $n $3; elif [ -f $f ]; then cat $f > $n; chown $3 $n; chmod 600 $n; fi; done; }'

die() { echo "ERROR: $*" >&2; exit 1; }
# adb shell de Android 4.x no devuelve el código de salida
root() {
  local out
  out="$(adb shell "su -c '$1'; echo __rc=\$?" | tr -d '\r')"
  grep -q '^__rc=0$' <<<"${out}"
}
closed() { [[ "$(adb shell ps)" != *oldiechat/bin/nchat* ]] || die "OldieChat está abierto en el teléfono: ciérralo y repite"; }

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"; adb shell "rm -r ${T}" >/dev/null 2>&1 || true' EXIT

case "${1:-}" in
  respaldar)
    closed
    root "ls ${N}/profiles/WhatsAppMd_*" || die "no hay sesión de OldieChat en el teléfono"
    root "rm -r ${T} 2>/dev/null; mkdir ${T}; chown 2000:2000 ${T}; chmod 700 ${T}; ${F}; \
      c ${N}/profiles ${T}/profiles 2000:2000; c ${N}/history ${T}/history 2000:2000" || die "no pude copiar la sesión"
    adb pull "${T}" "${tmp}/session" || die "no pude traer la sesión al PC"
    out="${HOME}/Respaldos/oldiechat/oldiechat-sesion-$(date +%Y%m%d-%H%M).tar.gz"
    mkdir -p "${out%/*}" && chmod 700 "${out%/*}"
    (umask 077 && tar -C "${tmp}" -czf "${out}" session) && chmod 600 "${out}"
    echo "Respaldo: ${out}"
    ;;
  restaurar)
    [[ -f "${2:-}" ]] || die "uso: $0 restaurar <archivo>"
    closed
    root "[ -f ${H%/home}/oldiechat.sh ]" || die "OldieChat no está instalado: ejecuta antes ./install.sh"
    ! root "ls ${N}/profiles/WhatsAppMd_*" || die "el teléfono ya tiene una sesión de OldieChat"
    tar -C "${tmp}" -xzf "$2" && [[ -d "${tmp}/session/profiles" ]] || die "$2 no es un respaldo de OldieChat"
    adb shell "rm -r ${T} 2>/dev/null; mkdir ${T}; chmod 700 ${T}" >/dev/null
    for d in profiles history; do adb push "${tmp}/session/${d}" "${T}/${d}" || die "no pude copiar la sesión al teléfono"; done
    root "${F}; c ${T}/profiles ${N}/profiles 0:0; c ${T}/history ${N}/history 0:0; chown 0:0 ${H}; chmod 700 ${H}" \
      || die "no pude restaurar la sesión"
    echo "Sesión restaurada. En TermOne Plus escribe: wsp"
    ;;
  *) die "uso: $0 respaldar | restaurar <archivo>" ;;
esac
