#!/usr/bin/env bash

# "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"

DIR="$(dirname "$0")"

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
while :; do
  for frame in "${animation_frames[@]}"; do
    IFS=$'\t' read -r _ status <<< "$("$DIR/get-active-player.sh")"

    if [ "$status" == "Playing" ]; then
        echo "$frame"
    else
        echo ""
    fi
    sleep 0.1
  done
done
