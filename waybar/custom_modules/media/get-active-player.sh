#!/usr/bin/env bash

STATE_FILE="/tmp/waybar-media-active"

player=$(cat "$STATE_FILE" 2>/dev/null)

# Trust the state file as long as it still points at a player that's actually playing
if [ -n "$player" ] && [ "$(playerctl -p "$player" status 2>/dev/null)" = "Playing" ]; then
    echo "$player"
    exit 0
fi

# Fallback: state file missing/stale (e.g. daemon not running yet) -> poll directly
players=$(playerctl -l 2>/dev/null)
[ -z "$players" ] && exit 0

while IFS= read -r p; do
    if [ "$(playerctl -p "$p" status 2>/dev/null)" = "Playing" ]; then
        echo "$p"
        exit 0
    fi
done <<< "$players"

echo "$players" | head -n1
