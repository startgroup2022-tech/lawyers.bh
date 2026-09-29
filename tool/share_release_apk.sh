#!/usr/bin/env bash
# Restore the APK share after a runtime restart wipes /tmp and kills the server.
# Usage: bash tool/share_release_apk.sh
set -u

APP="/workspace/project/lawyers-bh-client/flutter_app"
SHARE="/tmp/apk_share"
PORT=12001

mkdir -p "$SHARE"

for f in \
  "build/app/outputs/flutter-apk/app-release.apk:lawyers-bh-release.apk" \
  "build/app/outputs/bundle/release/app-release.aab:lawyers-bh-release.aab"
do
  src="$APP/${f%%:*}"
  dst="$SHARE/${f##*:}"
  if [ -f "$src" ]; then
    cp -f "$src" "$dst"
    echo "restored $(basename "$dst") ($(stat -c%s "$dst") bytes)"
  else
    echo "MISSING source: $src" >&2
  fi
done

if ! pgrep -f "http.server $PORT" >/dev/null 2>&1; then
  (cd "$SHARE" && nohup python3 -m http.server "$PORT" --bind 0.0.0.0 \
      >/tmp/apk_srv.log 2>&1 &)
  sleep 2
  echo "started server on $PORT"
else
  echo "server already running on $PORT"
fi

curl -sS -o /dev/null -w "apk=%{http_code} size=%{size_download}\n" \
  "http://127.0.0.1:$PORT/lawyers-bh-release.apk"
