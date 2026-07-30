#!/usr/bin/env bash

players=$(playerctl -l 2>/dev/null)
[ -z "$players" ] && exit 0

# Prefer whichever player is actually playing right now
while IFS= read -r p; do
    if [ "$(playerctl -p "$p" status 2>/dev/null)" = "Playing" ]; then
        echo "$p"
        exit 0
    fi
done <<< "$players"

# Nothing playing -> fall back to the first available player (e.g. Paused)
echo "$players" | head -n1
