#!/usr/bin/env bash

DIR="$(dirname "$0")"

# "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")
while :; do
  for frame in "${animation_frames[@]}"; do
    player=$("$DIR/get-active-player.sh")
    status=""
    if [ -n "$player" ]; then
        status=$(playerctl -p "$player" status 2>/dev/null)
    fi

    if [ "$status" == "Playing" ]; then
        echo "$frame"
    else
        echo ""
    fi
    sleep 0.1
  done
done
