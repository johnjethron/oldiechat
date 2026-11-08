#!/system/bin/sh
# sms-bridge.sh - puente de OldieChat SMS con WhatsApp (prototipo con root, Área 5, etapa 2a).
#
# Va en el teléfono junto a player.jar (player/build.sh); el motor ya vinculado
# está en /data/local/tmp/oldiechat-engine/. Se ejecuta a mano con root:
#   adb push scripts/sms-bridge.sh <player.jar> /data/local/tmp/
#   adb shell su -c "sh /data/local/tmp/sms-bridge.sh [-t] [-s] <número del dueño con +56>"
#   -t  no envía SMS: los escribe en sms-bridge.log con su largo en septetos
#   -s  todo envío por WhatsApp va al chat propio del dueño (Saved Messages)
# Como root solo corre lo de /system/bin; el motor corre como shell (uid 2000).
# Sin read -t (mksh R40): si el motor se cuelga, el script queda esperando.
# Diseño y comandos: docs/SMS_BRIDGE.md.

# Textos: marcadores, los escribe el dueño (lista y largos en docs/ESTADO.md).
T_BIENV='[BIENVENIDA]'
T_AYUDA='[AYUDA]'
T_PIE='[PIE]'
T_OK='[OK]'
T_NOENV='[NO SE ENVIO]'
T_NADA='[SIN NUEVOS]'
T_SESION='[SESION CERRADA]'
T_YO='Yo'

set -fU
while :; do case $1 in -t) TEST=1; shift ;; -s) SELF=1; shift ;; *) break ;; esac; done
NUM="${1:?uso: sms-bridge.sh [-t] [-s] <número>}"
D="${0%/*}"; LOG="$D/sms-bridge.log"; E=/data/local/tmp/oldiechat-engine
TMPDIR=/data/local/tmp
N9=${NUM#"${NUM%?????????}"}          # se comparan los últimos 9 dígitos
ME="${NUM#+}@s.whatsapp.net"          # chat propio, para -s
HELLO="$D/sms-bridge-$N9"             # existe si ya se envió la bienvenida
bs='\' nl='
' A=$(print '\001') B=$(print '\002') C=$(print '\003')
log() { print -r -- "$(date '+%H:%M:%S') $*" >> "$LOG"; }

# Motor como coproceso; el filtro deja pasar solo respuestas y avisos de sesión.
su 2000 -c "cd $E && exec ./oldiechat-engine run --data data --glyphs sms" 2>>"$D/sms-bridge-motor.log" |
  while read -r l; do
    case $l in '{"type":"message",'*|'{"type":"audio_ready",'*|'{"type":"error",'*'"id":'*) ;; *) print -r -- "$l" ;; esac
  done |&
trap 'print -p "{\"cmd\":\"quit\"}"' EXIT
trap 'exit' INT TERM HUP

ask() {  # envía la orden $1 y deja en R la respuesta de tipo $2 (o el error)
  print -p -r -- "$1"
  while read -p -r R; do
    case $R in "{\"type\":\"$2\""*|'{"type":"error"'*) break ;; '{"type":"logged_out"'*|'{"type":"need_pairing"'*) OUT=1 ;; esac
  done
  [ -n "$R" ] || { log "el motor terminó"; exit 1; }
  # una barra invertida del JSON pasa a A; \\ queda en C y \" en B
  R=${R//\\/$A}; R=${R//$A$A/$C}; R=${R//$A\"/$B}
}

val() {  # valor de texto del campo $1 en $2, sin escapes, en v
  v=${2#*"\"$1\":\""}; [ "$v" = "$2" ] && { v=; return; }; v=${v%%\"*}
  v=${v//${A}n/ }; v=${v//${A}t/ }; v=${v//${A}r/}
  v=${v//${A}u0026/&}; v=${v//${A}u003c/<}; v=${v//${A}u003e/>}
  v=${v//$A/}; v=${v//$B/\"}; v=${v//$C/$bs}
}

sept() {  # septetos GSM de $1 en s: los caracteres extendidos valen 2
  typeset e y; s=${#1}; for e in '^' '{' '}' '[' ']' '~' '|' '€' "$bs"; do y=${1//"$e"/}; s=$((s + ${#1} - ${#y})); done
}

pre() { p=; [ -e "$HELLO" ] || p="$T_BIENV$nl"; }

say() {  # envía $1 al dueño (siempre a NUM), con el límite de 30 por hora
  now=$(date +%s); k= n=0
  for x in $sent; do [ $((now - x)) -lt 3600 ] && { k="$k $x"; n=$((n + 1)); }; done; sent=$k
  [ $n -ge 30 ] && { log "límite de 30 SMS por hora: no se envió"; return; }
  sent="$sent $now"; sept "$1"; : > "$HELLO"
  if [ -n "$TEST" ]; then log "SMS septetos=$s: ${1//$nl/ | }"; return; fi
  N="$NUM" T="$1" CLASSPATH="$D/player.jar" su 1001 -c 'app_process /system/bin cl.oldiechat.sms.SmsSend "$N" "$T"' </dev/null
  log "SMS septetos=$s"
}

menu() {  # hasta 9 personas en 1 SMS; los números quedan fijos hasta el próximo menú
  ask '{"cmd":"chats","kind":"people"}' chats
  pre; h=$p; [ -n "$okw" ] && h="$h$T_OK $okw$nl"; okw=
  J=${R#*'"chats":['}; m= i=0
  while [ $i -lt 9 ]; do
    case $J in *'"chat":"'*) ;; *) break ;; esac
    val chat "$J"; ch=$v; val name "$J"; [ -n "$v" ] || v=${ch%@*}
    J=${J#*'"unread":'}; u=${J%%[!0-9]*}
    l="$((i + 1)) $v"; [ "${u:-0}" -gt 0 ] && l="$l ($u)"
    sept "$h$m$l$nl$T_PIE"; [ $s -gt 160 ] && break
    i=$((i + 1)); m="$m$l$nl"; eval "C$i=\$ch W$i=\$v"
  done
  while [ $i -lt 9 ]; do i=$((i + 1)); eval "C$i= W$i="; done
  say "$h$m$T_PIE"
}

open() {  # mensajes nuevos de la persona $1 en 1 SMS, los más recientes
  eval "ch=\$C$1 w=\$W$1"; [ -n "$ch" ] || { menu; return; }
  lastc=$ch lastw=$w
  ask "{\"cmd\":\"messages\",\"chat\":\"$ch\"}" messages
  J=${R#*'"messages":['}; n=0
  while :; do
    case $J in *'{"type":"message"'*) ;; *) break ;; esac
    J=${J#*'{"type":"message"'}; o=${J%%'{"type":"message"'*}
    case $o in *'"from_me":true'*) who=$T_YO ;; *) who=${w%% *}; [ ${#who} -gt 8 ] && who=${who%"${who#????????}"} ;; esac
    val text "$o"
    case $o in *'"audio":true'*)
      x=${o#*'"seconds":'}; x=${x%%[!0-9]*}; x=${x:-0}; mm=$((x / 60)) ss=$((x % 60))
      [ $mm -lt 10 ] && mm=0$mm; [ $ss -lt 10 ] && ss=0$ss; v="audio $mm.$ss" ;;
    esac
    n=$((n + 1)); eval "M$n=\"\$who: \$v\""
  done
  pre
  [ $n -gt 0 ] || { say "$p$T_NADA $w"; return; }
  t=
  while [ $n -gt 0 ]; do
    eval "l=\$M$n"; n=$((n - 1)); x=$l; [ -n "$t" ] && x="$l$nl$t"
    sept "$p$x"; [ $s -le 160 ] && { t=$x; continue; }
    [ -n "$t" ] && break
    while [ $s -gt 158 ]; do [ $s -gt 170 ] && l=${l%??????????} || l=${l%?}; sept "$p$l"; done
    t="$l.."; break
  done
  say "$p$t"
}

send() {  # escribe $3 a $1 (nombre $2); silencio si sale bien
  lastc=$1 lastw=$2; c=$1; [ -n "$SELF" ] && c=$ME
  x=${3//\\/$bs$bs}; x=${x//\"/$bs\"}; x=${x//$nl/${bs}n}
  ask "{\"cmd\":\"send\",\"chat\":\"$c\",\"text\":\"$x\"}" sent
  case $R in
    '{"type":"sent"'*) okw=$2; log "WhatsApp enviado a $2" ;;
    *) okw=; log "WhatsApp falló: $R"; pre; say "$p$T_NOENV $2" ;;
  esac
}

cmd() {  # atiende un SMS del dueño ($1); vacío = llamada perdida
  b=${1%"${1##*[! ]}"}; b=${b#"${b%%[! ]*}"}; typeset -l lc="$b"
  [ -z "$OUT" ] || { say "$T_SESION"; return; }
  case $lc in
    ''|0) menu ;;
    a) : > "$HELLO"; say "$T_AYUDA" ;;   # la ayuda trae el logo: sin bienvenida
    [1-9]) open "$lc" ;;
    00|g|g[1-9]|g[1-9]' '*) menu ;;      # etapa 2b
    [1-9]' '*)
      eval "c=\$C${lc%% *} w=\$W${lc%% *}"; x=${b#?}; x=${x#"${x%%[! ]*}"}
      if [ -n "$c" ]; then send "$c" "$w" "$x"; else menu; fi ;;
    *) if [ -n "$lastc" ]; then send "$lastc" "$lastw" "$b"; else menu; fi ;;
  esac
}

q() { content query --uri "$1" --projection "$2" --where "$3" --sort "_id ASC"; }
top() { content query --uri "$1" --projection _id --sort "_id DESC" | while read -r l; do l=${l#*_id=}; print -r -- "${l%%,*}"; break; done; }

ls=$(top content://sms/inbox); lk=$(top content://call_log/calls)
log "inicio pid $$, sms _id>${ls:-0}, llamadas _id>${lk:-0}${TEST:+, prueba}${SELF:+, solo chat propio}"
echo "Puente SMS para $NUM (pid $$); registro en $LOG. Se detiene con Ctrl-C."

while :; do
  while read -r l; do
    case $l in Row:*) ;; *) continue ;; esac
    r=${l#*_id=}; lk=${r%%,*}; log "llamada perdida _id=$lk"; cmd ''
  done <<EOF
$(q content://call_log/calls _id:type "_id>${lk:-0} AND type=3 AND number LIKE '%$N9'")
EOF
  while read -r l; do
    case $l in Row:*) ;; *) continue ;; esac
    r=${l#*_id=}; ls=${r%%,*}; log "SMS _id=$ls"; cmd "${r#*body=}"
  done <<EOF
$(q content://sms/inbox _id:body "_id>${ls:-0} AND address LIKE '%$N9'")
EOF
  sleep 2
done
