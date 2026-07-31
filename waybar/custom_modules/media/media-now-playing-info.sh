#!/usr/bin/env bash

DIR="$(dirname "$0")"
CACHE_FILE="/tmp/waybar-media-title-cache"

IFS=$'\t' read -r player status <<< "$("$DIR/get-active-player.sh")"

if [ -z "$player" ]; then
    rm -f "$CACHE_FILE"
    exit 0
fi

info=$(playerctl -p "$player" metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)

if [ -z "$info" ]; then
    sleep 0.1
    info=$(playerctl -p "$player" metadata --format '{{ title }} - {{ artist }}' 2>/dev/null)
fi

if [ -n "$info" ]; then
    echo "$player:$info" > "$CACHE_FILE"
    echo "$info"
    exit 0
fi

cached=$(cat "$CACHE_FILE" 2>/dev/null)
cached_player="${cached%%:*}"
cached_value="${cached#*:}"

if [ "$cached_player" = "$player" ] && [ -n "$cached_value" ]; then
    echo "$cached_value"
fi
