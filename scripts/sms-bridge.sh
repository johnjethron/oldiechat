#!/system/bin/sh
# sms-bridge.sh - puente de OldieChat SMS con WhatsApp (prototipo con root, Área 5, etapas 2a y 2b).
#
# Va en el teléfono junto a player.jar (player/build.sh); el motor ya vinculado
# está en /data/local/tmp/oldiechat-engine/. Se ejecuta a mano como shell (sin root):
#   adb push scripts/sms-bridge.sh <player.jar> /data/local/tmp/
#   adb shell sh /data/local/tmp/sms-bridge.sh [-t] [-s] <número del dueño con +56>
#   -t  no envía SMS: los escribe en sms-bridge.log con su largo en septetos
#   -s  todo envío por WhatsApp va al chat propio del dueño (Saved Messages)
# El motor corre como shell: su 2000 lo deja sin el grupo inet y sin red. Root (un
# solo su) solo consulta inbox y llamadas, y su 1001 envía; los dos con /system/bin.
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
[ "$1" = --poll ] && { POLL=$2; shift 2; }   # parte root, ver abajo
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

q() { content query --uri "$1" --projection "$2" --where "$3" --sort "_id ASC"; }
top() { content query --uri "$1" --projection _id --sort "_id DESC" | while read -r l; do l=${l#*_id=}; print -r -- "${l%%,*}"; break; done; }

if [ -n "$POLL" ]; then  # root: cada 2 s escribe "llamada <_id>" o "sms <_id> <texto>"; termina con el script
  ls=$(top content://sms/inbox); lk=$(top content://call_log/calls); print "inicio ${ls:-0} ${lk:-0}"
  while [ -d /proc/$POLL ]; do
    while read -r l; do case $l in Row:*) r=${l#*_id=}; lk=${r%%,*}; print "llamada $lk" ;; esac; done <<EOF
$(q content://call_log/calls _id:type "_id>${lk:-0} AND type=3 AND number LIKE '%$N9'")
EOF
    while read -r l; do case $l in Row:*) r=${l#*_id=}; ls=${r%%,*}; print -r -- "sms $ls ${r#*body=}" ;; esac; done <<EOF
$(q content://sms/inbox _id:body "_id>${ls:-0} AND address LIKE '%$N9'")
EOF
    sleep 2
  done
  exit
fi

# Motor como coproceso en 3 y 4; el filtro deja pasar solo respuestas y avisos de sesión.
(cd $E && exec ./oldiechat-engine run --data data --glyphs sms) 2>>"$D/sms-bridge-motor.log" |
  while read -r l; do
    case $l in '{"type":"message",'*|'{"type":"audio_ready",'*|'{"type":"error",'*'"id":'*) ;; *) print -r -- "$l" ;; esac
  done |&
exec 3>&p 4<&p
trap 'print -u3 "{\"cmd\":\"quit\"}"' EXIT
trap 'exit' INT TERM HUP

ask() {  # envía la orden $1 y deja en R la respuesta de tipo $2 (o el error)
  print -u3 -r -- "$1"
  while read -u4 -r R; do
    case $R in "{\"type\":\"$2\""*|'{"type":"error"'*) break ;; '{"type":"logged_out"'*|'{"type":"need_pairing"'*) OUT=1 ;; esac
  done
  [ -n "$R" ] || { log "el motor terminó"; exit 1; }
  # una barra invertida del JSON pasa a A; \\ queda en C y \" en B
  R=${R//\\/$A}; R=${R//$A$A/$C}; R=${R//$A\"/$B}
}

val() {  # valor de texto del campo $1 en $2, sin escapes, en v
  k="\"$1\":\""; v=${2#*"$k"}; [ "$v" = "$2" ] && { v=; return; }; v=${v%%\"*}
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

load() {  # los 9 chats más recientes de tipo $1 en $2C1.. (chat), $2W1.. (nombre) y $2U1.. (sin leer)
  ask "{\"cmd\":\"chats\",\"kind\":\"$1\"}" chats
  J=${R#*'"chats":['}; i=0
  while [ $i -lt 9 ]; do
    i=$((i + 1)); ch= v= u=0
    case $J in *'"chat":"'*)
      val chat "$J"; ch=$v; val name "$J"; [ -n "$v" ] || v=${ch%@*}
      J=${J#*'"unread":'}; u=${J%%[!0-9]*} ;;
    esac
    eval "$2C$i=\$ch $2W$i=\$v $2U$i=\$u"
  done
}

menu() {  # hasta 9 chats de tipo $1 (prefijo $2) en 1 SMS; los números quedan fijos hasta el próximo menú
  load "$1" "$2"
  pre; h=$p; [ -n "$okw" ] && h="$h$T_OK $okw$nl"; okw=
  m= i=0
  while [ $i -lt 9 ]; do
    eval "ch=\$$2C$((i + 1)) v=\$$2W$((i + 1)) u=\$$2U$((i + 1))"; [ -n "$ch" ] || break
    l="$((i + 1)) $v"; [ "$u" -gt 0 ] && l="$l ($u)"
    sept "$h$m$l$nl$T_PIE"; [ $s -gt 160 ] && break
    i=$((i + 1)); m="$m$l$nl"
  done
  while [ $i -lt 9 ]; do i=$((i + 1)); eval "$2C$i= $2W$i="; done
  say "$h$m$T_PIE"
}

msgs() {  # mensajes nuevos del chat $1 en $2 1..n (del más antiguo al más nuevo) y su hora en $2 t1..;
          # quien escribe: el nombre de pila de $3, o en grupos ($3 vacío) el de cada mensaje
  ask "{\"cmd\":\"messages\",\"chat\":\"$1\"}" messages
  J=${R#*'"messages":['}; n=0
  while :; do
    case $J in *'{"type":"message"'*) ;; *) break ;; esac
    J=${J#*'{"type":"message"'}; o=${J%%'{"type":"message"'*}
    case $o in *'"from_me":true'*) who=$T_YO ;; *)
      who=$3; [ -n "$who" ] || { val name "$o"; who=$v; }
      [ -n "$who" ] || { val sender "$o"; who=${v%%[@:]*}; }
      who=${who%% *}; [ ${#who} -gt 8 ] && who=${who%"${who#????????}"} ;;
    esac
    val text "$o"
    case $o in *'"audio":true'*)
      x=${o#*'"seconds":'}; x=${x%%[!0-9]*}; x=${x:-0}; mm=$((x / 60)) ss=$((x % 60))
      [ $mm -lt 10 ] && mm=0$mm; [ $ss -lt 10 ] && ss=0$ss; v="audio $mm.$ss" ;;
    esac
    x=${o#*'"time":'}; x=${x%%[!0-9]*}
    n=$((n + 1)); eval "$2$n=\"\$who: \$v\" $2t$n=\${x:-0}"
  done
}

pack() {  # en t, las líneas de $1 desde la $2 hacia atrás (de la más nueva), hasta $3 y lo que quepa con el prefijo p
  t= j=$2 k=0
  while [ $j -gt 0 ] && [ $k -lt $3 ]; do
    eval "l=\$$1$j"; [ -n "$l" ] || break; j=$((j - 1)) k=$((k + 1))
    x=$l; [ -n "$t" ] && x="$l$nl$t"
    sept "$p$x"; [ $s -le 160 ] && { t=$x; continue; }
    [ -n "$t" ] && break
    while [ $s -gt 158 ]; do [ $s -gt 170 ] && l=${l%??????????} || l=${l%?}; sept "$p$l"; done
    t="$l.."; break
  done
}

open() {  # mensajes nuevos de la persona $1 en 1 SMS, los más recientes
  eval "ch=\$C$1 w=\$W$1"; [ -n "$ch" ] || { menu people; return; }
  lastc=$ch lastw=$w
  msgs "$ch" M "$w"; pre
  [ $n -gt 0 ] || { say "$p$T_NADA $w"; return; }
  pack M $n 99; say "$p$t"
}

news() {  # 00: lo nuevo de cada persona en 1 SMS, cada línea con su número de menú; si no cabe, lo más reciente
  load people ""; pre; h=$p; [ -n "$okw" ] && h="$h$T_OK $okw$nl"; okw=
  i=0
  while [ $i -lt 9 ]; do
    i=$((i + 1)); eval "ch=\$C$i w=\$W$i u=\$U$i H$i=0"
    [ "$u" -gt 0 ] && { msgs "$ch" P${i}_ "$w"; eval "H$i=\$n"; }
  done
  k=0   # mezcla de la más nueva a la más antigua, en L30 hacia abajo
  while [ $k -lt 25 ]; do
    b=0 bt=-1 i=0
    while [ $i -lt 9 ]; do
      i=$((i + 1)); eval "j=\$H$i"; [ $j -gt 0 ] || continue
      eval "x=\$P${i}_t$j"; [ $x -gt $bt ] && b=$i bt=$x
    done
    [ $b -gt 0 ] || break
    eval "j=\$H$b"; eval "L$((30 - k))=\"$b \$P${b}_$j\" H$b=$((j - 1))"; k=$((k + 1))
  done
  eval "L$((30 - k))="
  p=$h; [ $k -gt 0 ] || { say "$p$T_NADA"; return; }
  pack L 30 99; say "$p$t"
}

send() {  # escribe $3 a $1 (nombre $2); silencio si sale bien
  c=$1 to=$2; [ -n "$SELF" ] && c=$ME to="Saved Messages"
  x=${3//\\/$bs$bs}; x=${x//\"/$bs\"}; x=${x//$nl/${bs}n}
  ask "{\"cmd\":\"send\",\"chat\":\"$c\",\"text\":\"$x\"}" sent
  case $R in
    '{"type":"sent"'*) okw=$2; log "WhatsApp enviado a $to" ;;
    *) okw=; log "WhatsApp falló: $R"; pre; say "$p$T_NOENV $2" ;;
  esac
}

cmd() {  # atiende un SMS del dueño ($1); vacío = llamada perdida
  b=${1%"${1##*[! ]}"}; b=${b#"${b%%[! ]*}"}; typeset -l lc="$b"
  [ -z "$OUT" ] || { say "$T_SESION"; return; }
  case $lc in
    ''|0) menu people ;;
    00) news ;;
    a) : > "$HELLO"; say "$T_AYUDA" ;;   # la ayuda trae el logo: sin bienvenida
    [1-9]) open "$lc" ;;
    g|g[1-9]|g[1-9]' '*) menu people ;;  # grupos: siguiente paso
    [1-9]' '*)
      eval "c=\$C${lc%% *} w=\$W${lc%% *}"; x=${b#?}; x=${x#"${x%%[! ]*}"}
      if [ -n "$c" ]; then lastc=$c lastw=$w; send "$c" "$w" "$x"; else menu people; fi ;;
    *) if [ -n "$lastc" ]; then send "$lastc" "$lastw" "$b"; else menu people; fi ;;
  esac
}

su -c "sh $0 --poll $$ $NUM" </dev/null |&
echo "Puente SMS para $NUM (pid $$); registro en $LOG. Se detiene con Ctrl-C."
while read -p -r k id l; do
  case $k in
    inicio) log "inicio pid $$, sms _id>$id, llamadas _id>$l${TEST:+, prueba}${SELF:+, solo chat propio}" ;;
    llamada) log "llamada perdida _id=$id"; cmd '' ;;
    sms) log "SMS _id=$id"; cmd "$l" ;;
  esac
done
log "la consulta con root terminó"
