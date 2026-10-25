#!/system/bin/sh
# audio.sh - reproduce en segundo plano los audios que abre nchat.
#
#   audio.sh play <archivo>   reproduce (si ya suena ese mismo archivo, lo detiene)
#   audio.sh stop             detiene la reproducción
#
# Las notas de voz Ogg Opus (.oga/.ogg/.opus) se convierten antes a WAV con
# oldiechat-audio; mp3, m4a, aac, amr y wav se reproducen tal cual. El audio sale
# por el MediaPlayer de Android (player.jar, lanzado con app_process).
# Otros adjuntos (imágenes, documentos) se ignoran.
#
# Cada paso queda en $HOME/audio.log (oldiechat.sh lo rota al arrancar).

case "$0" in
  */*) D="${0%/*}" ;;
  *)   D="." ;;
esac
D="$(cd "$D" && pwd)"

umask 077
HOME="${HOME:-$D/home}"
LOG="$HOME/audio.log"
STATE="${TMPDIR:-$HOME/tmp}/audio"
[ -d "$STATE" ] || mkdir "$STATE" || exit 1

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] $*" >> "$LOG"
}

running() {
  [ -f "$STATE/pid" ] && kill -0 "$(cat "$STATE/pid")" 2>/dev/null
}

stop() {
  if [ -f "$STATE/pid" ]; then
    log "stop: detengo pid $(cat "$STATE/pid")"
    kill "$(cat "$STATE/pid")" 2>/dev/null
    rm "$STATE/pid" "$STATE/file" 2>/dev/null
  fi
}

play() {
  src="$1"
  ids="$(id)"
  log "play: $src (${ids%% *})"
  if [ ! -f "$src" ]; then
    log "play: ERROR el archivo no existe"
    return 1
  fi
  if running && [ "$(cat "$STATE/file" 2>/dev/null)" = "$src" ]; then
    log "play: ya sonaba este archivo, se detiene"
    stop
    return 0
  fi
  stop

  case "$src" in
    *.oga|*.ogg|*.opus|*.OGA|*.OGG|*.OPUS)
      out="$STATE/play.wav"
      if ! err="$("$D/bin/oldiechat-audio" convert "$src" "$out" 2>&1)"; then
        log "convert: ERROR $err"
        return 1
      fi
      log "convert: ok -> $out"
      ;;
    *.mp3|*.m4a|*.aac|*.amr|*.wav|*.MP3|*.M4A|*.AAC|*.AMR|*.WAV)
      out="$src"
      ;;
    *)
      log "play: no es audio, se ignora"
      return 0
      ;;
  esac

  [ -n "$BOOTCLASSPATH" ] || log "play: AVISO BOOTCLASSPATH vacío, app_process puede fallar"
  echo "$src" > "$STATE/file"
  (
    # que el reproductor no muera si se cierra la sesión que lo lanzó
    trap '' HUP
    CLASSPATH="$D/lib/player.jar" app_process /system/bin cl.oldiechat.player.Player "$out" \
      </dev/null >>"$LOG" 2>&1 &
    echo $! > "$STATE/pid"
    log "player: iniciado pid $!"
    wait $!
    log "player: terminó (código $?)"
  ) &
}

case "$1" in
  play) play "$2" ;;
  stop) stop ;;
  *) echo "uso: audio.sh play <archivo> | stop" >&2; exit 2 ;;
esac
