#!/usr/bin/env bash
set -euo pipefail
CHS=/home/ubuntu/.cache/hyperframes/chrome/chrome-headless-shell/linux-152.0.7928.2/chrome-headless-shell-linux64/chrome-headless-shell
OUT=/opt/cursor/artifacts/my-video-final-frames
PAGES=/workspace/my-video/final-frame-pages
mkdir -p "$OUT" /tmp/chs-logs

frames=(
  01-hook 02-setup 03-warning 04-fight-knife 05-fight-table-leg
  06-body-weight 07-death-detail 08-aftermath 09-investigation 10-court 11-ending
)

for f in "${frames[@]}"; do
  PROFILE=/tmp/chs-profile-$f
  rm -rf "$PROFILE"
  # Chrome writes --screenshot relative to CWD sometimes; use absolute and also check CWD
  cd /tmp
  rm -f /tmp/screenshot.png
  timeout 40 "$CHS" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --no-sandbox \
    --allow-file-access-from-files \
    --user-data-dir="$PROFILE" \
    --window-size=1920,1080 \
    --virtual-time-budget=7000 \
    --screenshot="$OUT/${f}.png" \
    "file://$PAGES/${f}.html" \
    >"/tmp/chs-logs/${f}.log" 2>&1 || true

  if [[ ! -s "$OUT/${f}.png" ]] && [[ -s /tmp/screenshot.png ]]; then
    mv /tmp/screenshot.png "$OUT/${f}.png"
  fi

  # Some builds write next to the HTML
  if [[ ! -s "$OUT/${f}.png" ]] && [[ -s "$PAGES/screenshot.png" ]]; then
    mv "$PAGES/screenshot.png" "$OUT/${f}.png"
  fi

  size=$(stat -c%s "$OUT/${f}.png" 2>/dev/null || echo 0)
  mtime=$(stat -c%y "$OUT/${f}.png" 2>/dev/null | cut -c1-19 || echo missing)
  echo "SHOT $f size=$size mtime=$mtime"
  # keep profiles small
  rm -rf "$PROFILE"
done

ls -la "$OUT"
