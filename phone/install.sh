#!/usr/bin/env bash
#
# install.sh - instala OldieChat terminal en un Android 4.x rooteado por ADB.
#
# Hace, en el teléfono:
#   - copia el programa a /data/local/tmp/oldiechat (nchat, conversor y
#     reproductor de audio, terminfo, zonas horarias, scripts)
#   - mueve la sesión de una instalación anterior en /data/local/tmp/nchat
#   - copia key.conf, ui.conf, color.conf, glyphs.txt y guide.txt a la configuración (respalda los existentes)
#   - crea /system/etc/resolv.conf
#   - instala /system/etc/ssl/certs/ca-certificates.crt
#   - crea /system/bin/wsp para abrir OldieChat con un solo comando
#   - copia el ícono a /sdcard/OldieChat/oldiechat.png (para el acceso directo)
#   - instala la fuente de emoji en /system/fonts y la pone antes que la de Android
#     en /system/etc/fallback_fonts*.xml (respalda los originales como .orig);
#     hay que reiniciar el teléfono una vez
#
# Uso: ./install.sh
# Variables opcionales:
#   CA_BUNDLE    paquete de certificados del equipo (por defecto el del sistema)
#   NAMESERVERS  servidores DNS (por defecto "1.1.1.1 8.8.8.8")
#   ANDROID_SERIAL  número de serie del teléfono si hay más de uno conectado

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
if [[ -x "${HERE}/bin/nchat" ]]; then
  PKG="${HERE}"
else
  PKG="$(ls -d "${HERE}"/out/oldiechat-terminal-*-armv7 2>/dev/null | sort -V | tail -1)"
fi

DEST="/data/local/tmp/oldiechat"
OLD_DEST="/data/local/tmp/nchat"
CONFDIR="${DEST}/home/.config/nchat"
STAGE="/data/local/tmp/oldiechat-install"
NAMESERVERS="${NAMESERVERS:-1.1.1.1 8.8.8.8}"
CA_BUNDLE="${CA_BUNDLE:-}"

log() { printf '\n==> %s\n' "$*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

# adb shell de Android 4.x no devuelve el código de salida: se imprime uno
# propio al final y se comprueba aquí.
phone() {
  local out
  out="$(adb shell "$1; echo __rc=\$?" | tr -d '\r')"
  printf '%s\n' "${out}" | grep -v '^__rc=' || true
  grep -q '^__rc=0$' <<<"${out}"
}

root() {
  phone "su -c '$1'"
}

find_ca_bundle() {
  local f
  for f in "${CA_BUNDLE}" /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/cert.pem; do
    [[ -n "${f}" && -s "${f}" ]] && { echo "${f}"; return; }
  done
  die "no encontré certificados en el equipo; indica la ruta con CA_BUNDLE=..."
}

check() {
  log "Comprobando"
  [[ -n "${PKG}" && -x "${PKG}/bin/nchat" ]] || die "no encontré el paquete (ejecuta antes ./build.sh)"
  command -v adb >/dev/null || die "falta adb (sudo apt install adb)"
  local n
  n="$(adb devices | awk 'NR>1 && $2=="device"' | wc -l)"
  [[ -n "${ANDROID_SERIAL:-}" || "${n}" -eq 1 ]] || die "hay ${n} teléfonos conectados; usa ANDROID_SERIAL=..."
  root "id" | grep -q 'uid=0' || die "su no da root (acepta el permiso de SuperSU en el teléfono y repite)"
  phone "cat /proc/cpuinfo" | grep -qi 'ARMv7' || echo "Aviso: el teléfono no informa un procesador ARMv7"
  CA="$(find_ca_bundle)"
  echo "Paquete: ${PKG}"
  echo "Certificados: ${CA}"
}

push_files() {
  log "Copiando archivos al teléfono"
  phone "rm -r ${STAGE} 2>/dev/null; mkdir ${STAGE}" >/dev/null
  local d
  for d in bin lib terminfo zoneinfo config oldiechat.sh audio.sh; do
    adb push "${PKG}/${d}" "${STAGE}/${d}"
  done
  adb push "${CA}" "${STAGE}/ca-certificates.crt"
  if [[ -f "${PKG}/oldiechat.png" ]]; then
    phone "mkdir /sdcard/OldieChat 2>/dev/null; true" >/dev/null
    adb push "${PKG}/oldiechat.png" /sdcard/OldieChat/oldiechat.png
  fi

  printf '#!/system/bin/sh\nsu -c "TERM=${TERM:-screen-256color} %s/oldiechat.sh"\n' "${DEST}" > "${TMPDIR:-/tmp}/wsp.$$"
  adb push "${TMPDIR:-/tmp}/wsp.$$" "${STAGE}/wsp"
  rm -f "${TMPDIR:-/tmp}/wsp.$$"

  local resolv=""
  for ns in ${NAMESERVERS}; do resolv+="nameserver ${ns}"$'\n'; done
  printf '%s' "${resolv}" > "${TMPDIR:-/tmp}/resolv.$$"
  adb push "${TMPDIR:-/tmp}/resolv.$$" "${STAGE}/resolv.conf"
  rm -f "${TMPDIR:-/tmp}/resolv.$$"
}

install_program() {
  log "Instalando OldieChat terminal en ${DEST}"
  # Se reemplazan las carpetas completas con mv (misma partición); home/ se conserva.
  local d
  root "mkdir ${DEST} 2>/dev/null; chmod 755 ${DEST}"
  for d in bin lib terminfo zoneinfo oldiechat.sh audio.sh; do
    root "rm -r ${DEST}/${d} 2>/dev/null; mv ${STAGE}/${d} ${DEST}/${d}"
  done
  # adbd de Android 4.1 crea los archivos con 666/777: se quita la escritura a otros
  root "chmod -R 755 ${DEST}/bin ${DEST}/lib ${DEST}/terminfo ${DEST}/zoneinfo; \
    chmod 755 ${DEST}/oldiechat.sh ${DEST}/audio.sh"

  # instalación anterior con el nombre nchat: se conserva la sesión de WhatsApp
  if root "[ -d ${OLD_DEST}/home ] && [ ! -d ${DEST}/home ]" >/dev/null; then
    log "Moviendo la sesión de ${OLD_DEST} a ${DEST}"
    root "mv ${OLD_DEST}/home ${DEST}/home" || die "no pude mover ${OLD_DEST}/home"
    root "rm -r ${OLD_DEST}; touch ${DEST}/home/.migrated-from-nchat"
  fi
  # nchat guarda rutas absolutas de los adjuntos en su caché: tras migrar, la
  # ruta vieja debe seguir existiendo como enlace
  if root "[ -f ${DEST}/home/.migrated-from-nchat ] && [ ! -e ${OLD_DEST} ]" >/dev/null; then
    root "ln -s ${DEST} ${OLD_DEST}"
  fi

  log "Instalando la configuración (key, ui, color, glyphs, guide)"
  root "mkdir ${DEST}/home ${DEST}/home/.config ${CONFDIR} 2>/dev/null; chmod 700 ${DEST}/home"
  for f in key.conf ui.conf color.conf glyphs.txt guide.txt; do
    [[ -f "${PKG}/config/${f}" ]] || continue
    root "if [ -f ${CONFDIR}/${f} ]; then cat ${CONFDIR}/${f} > ${CONFDIR}/${f}.bak; chmod 600 ${CONFDIR}/${f}.bak; fi; \
      cat ${STAGE}/config/${f} > ${CONFDIR}/${f} && chmod 600 ${CONFDIR}/${f}"
  done
}

install_system() {
  log "Instalando resolv.conf, certificados y wsp en /system"
  local dev
  dev="$(phone "cat /proc/mounts" | awk '$2=="/system" {print $1; exit}')"
  [[ -n "${dev}" ]] || die "no encontré el montaje de /system"
  root "mount -o remount,rw ${dev} /system"
  local ok=0
  root "for f in /system/etc/resolv.conf /system/etc/ssl/certs/ca-certificates.crt; do \
      if [ -f \$f ] && [ ! -f \$f.orig ]; then cat \$f > \$f.orig; chmod 644 \$f.orig; fi; done; \
    mkdir /system/etc/ssl /system/etc/ssl/certs 2>/dev/null; \
    cat ${STAGE}/resolv.conf > /system/etc/resolv.conf && \
    cat ${STAGE}/ca-certificates.crt > /system/etc/ssl/certs/ca-certificates.crt && \
    cat ${STAGE}/wsp > /system/bin/wsp && \
    chmod 644 /system/etc/resolv.conf /system/etc/ssl/certs/ca-certificates.crt && \
    chmod 755 /system/etc/ssl /system/etc/ssl/certs /system/bin/wsp" || ok=1
  [[ ${ok} -ne 0 ]] || install_emoji_font || ok=1
  root "mount -o remount,ro ${dev} /system" || echo "Aviso: no pude volver /system a solo lectura"
  [[ ${ok} -eq 0 ]] || die "falló la escritura en /system"
}

# Fuente de emoji: se copia a /system/fonts y se agrega a la lista de respaldo de
# Android antes de AndroidEmoji.ttf (que dibuja las caras como robots). La lista
# se edita en el equipo; el original queda como .orig. Requiere /system en escritura.
EMOJI_FONT="NotoEmoji-OldieChat.ttf"
REBOOT=0
install_emoji_font() {
  [[ -f "${PKG}/fonts/${EMOJI_FONT}" ]] || return 0
  log "Instalando la fuente de emoji"
  adb push "${PKG}/fonts/${EMOJI_FONT}" "${STAGE}/${EMOJI_FONT}" >/dev/null
  root "cat ${STAGE}/${EMOJI_FONT} > /system/fonts/${EMOJI_FONT} && chmod 644 /system/fonts/${EMOJI_FONT}" || return 1

  local xml tmp
  tmp="$(mktemp -d)"
  for xml in $(phone "ls /system/etc/fallback_fonts*.xml"); do
    [[ "${xml}" == *.xml ]] || continue
    adb pull "${xml}" "${tmp}/f.xml" >/dev/null
    grep -q "${EMOJI_FONT}" "${tmp}/f.xml" && continue
    python3 -I -c '
import re, sys
path, font = sys.argv[1], sys.argv[2]
xml = open(path, encoding="utf-8").read()
family = "    <family>\n        <fileset>\n            <file>%s</file>\n        </fileset>\n    </family>\n" % font
m = re.search(r"[ \t]*<family>\s*<fileset>\s*<file>AndroidEmoji\.ttf</file>", xml)
pos = m.start() if m else xml.rindex("</familyset>")
open(path, "w", encoding="utf-8").write(xml[:pos] + family + xml[pos:])
' "${tmp}/f.xml" "${EMOJI_FONT}" || { rm -rf "${tmp}"; return 1; }
    adb push "${tmp}/f.xml" "${STAGE}/f.xml" >/dev/null
    root "[ -f ${xml}.orig ] || { cat ${xml} > ${xml}.orig; chmod 644 ${xml}.orig; }; \
      cat ${STAGE}/f.xml > ${xml} && chmod 644 ${xml}" || { rm -rf "${tmp}"; return 1; }
    echo "  ${xml}: fuente de emoji agregada"
    REBOOT=1
  done
  rm -rf "${tmp}"
}

finish() {
  log "Verificando"
  phone "rm -r ${STAGE}" >/dev/null || true
  root "${DEST}/oldiechat.sh --version" | grep -m1 '^nchat' || die "OldieChat no arrancó en el teléfono"
  root "${DEST}/bin/oldiechat-audio 2>&1; true" | grep -q 'uso:' || die "oldiechat-audio no arrancó en el teléfono"
  cat <<EOF

Listo. En TermOne Plus escribe:  wsp
Si es la primera vez, vincula WhatsApp desde el equipo:
  adb shell
  su -c "TERM=screen-256color ${DEST}/oldiechat.sh --setup"
EOF
  if [[ ${REBOOT} -eq 1 ]]; then
    echo
    echo "Reinicia el teléfono para que Android cargue la fuente de emoji."
  fi
}

check
push_files
install_program
install_system
finish
