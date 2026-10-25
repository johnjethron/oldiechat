#!/system/bin/sh
# oldiechat.sh - arranca OldieChat terminal (nchat) en Android con el entorno que necesita.
# Usa solo funciones del shell (Android 4.1 no trae dirname ni mkdir -p).

case "$0" in
  */*) D="${0%/*}" ;;
  *)   D="." ;;
esac
D="$(cd "$D" && pwd)"

# el shell de Android 4.1 usa umask 0: los datos de nchat deben ser privados
umask 077

export TERMINFO="$D/terminfo"
export HOME="${OLDIECHAT_HOME:-$D/home}"
export TMPDIR="$HOME/tmp"
export LANG="${LANG:-C.UTF-8}"

# Zona horaria: Android guarda la suya en persist.sys.timezone y usa un
# formato de tzdata propio, así que se apunta TZ al archivo incluido.
TZNAME="${OLDIECHAT_TZ:-$(getprop persist.sys.timezone 2>/dev/null)}"
if [ -n "$TZNAME" ] && [ -f "$D/zoneinfo/$TZNAME" ]; then
  export TZ="$D/zoneinfo/$TZNAME"
fi
export SSL_CERT_FILE="${SSL_CERT_FILE:-/system/etc/ssl/certs/ca-certificates.crt}"

case "$TERM" in
  ""|dumb) export TERM=vt100 ;;
esac

for d in "$HOME" "$HOME/tmp" "$HOME/.config"; do
  [ -d "$d" ] || mkdir "$d" || exit 1
done

# consultas que no abren la interfaz: no cierran otra sesión ni detienen el audio
case "$1" in
  -v|--version|-h|--help) exec "$D/bin/nchat" -d "$HOME/.config/nchat" "$@" ;;
esac

# registro del audio: se conserva solo la sesión anterior
[ ! -f "$HOME/audio.log" ] || mv "$HOME/audio.log" "$HOME/audio.log.1"

# un solo OldieChat a la vez: si quedó abierto en otra ventana de la terminal,
# se cierra antes (si no, este nchat termina en el acto por el bloqueo del perfil)
running_pid() {
  ps | while read -r line; do
    set -- $line
    eval "name=\${$#}"
    [ "$name" = "$D/bin/nchat" ] && echo "$2"
  done
}
old="$(running_pid)"
if [ -n "$old" ]; then
  kill -HUP $old 2>/dev/null
  i=0
  while [ -n "$(running_pid)" ] && [ $i -lt 10 ]; do
    sleep 1
    i=$((i + 1))
  done
fi

# registros de nchat: nchat solo guarda la sesión anterior (log.txt.1); se
# conservan las últimas 6
L="$HOME/.config/nchat/log.txt"
for i in 4 3 2 1; do
  [ ! -f "$L.$i" ] || mv "$L.$i" "$L.$((i + 1))"
done

"$D/bin/nchat" -d "$HOME/.config/nchat" "$@"
rc=$?

# que no siga sonando un audio al salir
"$D/audio.sh" stop
exit $rc
