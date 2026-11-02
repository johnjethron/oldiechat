#!/system/bin/sh
# sms-test.sh - prueba del menú de OldieChat SMS con datos ficticios, sin WhatsApp.
#
# Va en el teléfono junto a player.jar (player/build.sh) y se ejecuta a mano con root:
#   adb push scripts/sms-test.sh <player.jar> /data/local/tmp/
#   adb shell su -c "sh /data/local/tmp/sms-test.sh <número>"
# Responde solo a <número>, tal como aparece en el inbox. Se detiene con Ctrl-C.
# Cada respuesta queda en sms-test.log: segundos desde que llegó el SMS, caracteres y SMS usados.

NUM="${1:?uso: sms-test.sh <número>}"
D="${0%/*}"
LOG="$D/sms-test.log"
set -f
TMPDIR=/data/local/tmp

MENU=".-. OldieChat
'-' SMS
1 Ana (2)
2 Pedro
3 Mama (1)
# grupos  ? ayuda"

reply() {
  case "$st:$1" in
    *:0) st=m; text="$MENU" ;;
    *:\?) text="1-3 chat  # grupos  0 menu  ? ayuda" ;;
    *:\#) st=g; text=$'1 Familia (3)\n2 Futbol martes' ;;
    m:1) text=$'Ana: Hola! Llegas a las 8?\nAna: Llevo el pan, tu el queso' ;;
    m:2) text=$'Pedro: Ya viste el partido?\nYo: Que golazo el segundo' ;;
    m:3) text=$'Mama: Hijo, llamame cuando puedas\nMama: Compre las entradas' ;;
    g:1) text=$'Tia Rosa: Feliz cumple Ana!\nPapa: Asado el domingo\nAna: Yo llevo ensalada' ;;
    g:2) text=$'Juan: Somos 9, falta 1\nPedro: Invito a mi primo\nLuis: Cancha 3, 20:00' ;;
    *) st=m; text="$MENU" ;;
  esac
}

q() { content query --uri content://sms/inbox --projection "_id:date/1000 AS d:body" "$@"; }

st=m
last=$(q --sort "_id DESC" | while read -r l; do l=${l#*_id=}; echo "${l%%,*}"; break; done)
echo "Esperando SMS de $NUM desde _id>${last:-0} (pid $$)"

while :; do
  while read -r l; do
    case "$l" in Row:*) ;; *) continue ;; esac
    r=${l#*_id=}; last=${r%%,*}; r=${r#*d=}; got=${r%%,*}; set -- ${r#*body=}
    t=$(date +%s); reply "$1"
    n=0; [ ${#text} -le 160 ] && CLASSPATH="$D/player.jar" app_process /system/bin cl.oldiechat.sms.SmsSend "$NUM" "$text" && n=1
    e=$(date +%s)
    m="$(date '+%H:%M:%S') _id=$last cmd=$1 espera=$((t-got))s envio=$((e-t))s total=$((e-got))s chars=${#text} sms=$n"
    echo "$m"; echo "$m" >> "$LOG"
  done <<EOF
$(q --where "_id>${last:-0} AND address='$NUM'" --sort "_id ASC")
EOF
  sleep 2
done
