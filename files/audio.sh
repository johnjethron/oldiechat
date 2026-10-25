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

case "$0" in
  */*) D="${0%/*}" ;;
  *)   D="." ;;
esac
D="$(cd "$D" && pwd)"

umask 077
STATE="${TMPDIR:-$D/home/tmp}/audio"
[ -d "$STATE" ] || mkdir "$STATE" || exit 1

stop() {
  if [ -f "$STATE/pid" ]; then
    kill "$(cat "$STATE/pid")" 2>/dev/null
    rm "$STATE/pid" "$STATE/file" 2>/dev/null
  fi
}

play() {
  src="$1"
  if [ -f "$STATE/file" ] && [ "$(cat "$STATE/file")" = "$src" ] && \
     kill -0 "$(cat "$STATE/pid" 2>/dev/null)" 2>/dev/null; then
    stop
    return 0
  fi
  stop

  case "$src" in
    *.oga|*.ogg|*.opus|*.OGA|*.OGG|*.OPUS)
      out="$STATE/play.wav"
      "$D/bin/oldiechat-audio" convert "$src" "$out" || return 1
      ;;
    *.mp3|*.m4a|*.aac|*.amr|*.wav|*.MP3|*.M4A|*.AAC|*.AMR|*.WAV)
      out="$src"
      ;;
    *)
      return 0
      ;;
  esac

  CLASSPATH="$D/lib/player.jar" app_process /system/bin cl.oldiechat.player.Player "$out" \
    >/dev/null 2>&1 &
  echo $! > "$STATE/pid"
  echo "$src" > "$STATE/file"
}

case "$1" in
  play) play "$2" ;;
  stop) stop ;;
  *) echo "uso: audio.sh play <archivo> | stop" >&2; exit 2 ;;
esac
