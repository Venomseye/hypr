#!/usr/bin/env bash

# "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"

STATE_FILE="/tmp/waybar-media-active"
LOCK_FILE="/tmp/waybar-media-listener.lock"

# Background listener: keeps STATE_FILE pointed at whichever player is
# actively Playing, updated the instant playerctl reports a change.
#
# Guarded with flock so that if waybar restarts this script (respawning
# media-animation.sh), we don't end up with multiple overlapping
# listeners racing to write the same state file - only one instance
# ever runs; a re-run that finds the lock held just skips starting a
# second listener and lets the original keep running.
(
  flock -n 9 || exit 0
  playerctl --all-players --follow status --format '{{playerName}}|{{status}}' 2>/dev/null |
  while IFS='|' read -r player pstatus; do
      if [ "$pstatus" = "Playing" ]; then
          echo "$player" > "$STATE_FILE"
      else
          current=$(cat "$STATE_FILE" 2>/dev/null)
          if [ "$player" = "$current" ]; then
              rm -f "$STATE_FILE"
          fi
      fi
  done
) 9>"$LOCK_FILE" &

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
while :; do
  for frame in "${animation_frames[@]}"; do
    if [ -s "$STATE_FILE" ]; then
        echo "$frame"
    else
        echo ""
    fi
    sleep 0.1
  done
done
