#!/usr/bin/env bash

# Always does a fresh, authoritative check - no cached/background state
# to go stale. Prints "player<TAB>status" for whichever player is
# currently Playing, or falls back to the first player with any known
# status (e.g. Paused) if nothing is actively playing.

players=$(playerctl -l 2>/dev/null)
[ -z "$players" ] && exit 0

fallback_player=""
fallback_status=""

while IFS= read -r p; do
    s=$(playerctl -p "$p" status 2>/dev/null)
    if [ "$s" = "Playing" ]; then
        printf '%s\t%s\n' "$p" "$s"
        exit 0
    fi
    if [ -z "$fallback_player" ] && [ -n "$s" ]; then
        fallback_player="$p"
        fallback_status="$s"
    fi
done <<< "$players"

if [ -n "$fallback_player" ]; then
    printf '%s\t%s\n' "$fallback_player" "$fallback_status"
fi
