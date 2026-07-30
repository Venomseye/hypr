#!/usr/bin/env bash

# "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"

STATE_FILE="/tmp/waybar-media-active"

# Background listener: keeps STATE_FILE pointed at whichever player is
# actively Playing, updated the instant playerctl reports a change -
# no polling, so it reacts immediately even if several players change
# state around the same time.
(
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
) &

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
