#!/usr/bin/env bash

# Wraps zscroll's plain scrolling text output into waybar's JSON module
# format, adding a play/pause icon and a full-detail hover tooltip.
# Reads scrolled lines from stdin (piped in from zscroll).

DIR="$(dirname "$0")"

while IFS= read -r line; do
    IFS=$'\t' read -r player status <<< "$("$DIR/get-active-player.sh")"

    if [ -n "$player" ]; then
        full_title=$(playerctl -p "$player" metadata title 2>/dev/null)
        full_artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
        album=$(playerctl -p "$player" metadata album 2>/dev/null)

        icon="⏸"
        [ "$status" = "Paused" ] && icon="▶"
        tooltip="$full_title"
        [ -n "$full_artist" ] && tooltip="$tooltip
by $full_artist"
        [ -n "$album" ] && tooltip="$tooltip
$album"

        text="$icon $line"
    else
        text="$line"
        tooltip=""
    fi

    if command -v jq >/dev/null 2>&1; then
        jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
    else
        # jq not installed - fall back to basic manual JSON escaping
        esc_text=$(printf '%s' "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')
        esc_tooltip=$(printf '%s' "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
        printf '{"text": "%s", "tooltip": "%s"}\n' "$esc_text" "$esc_tooltip"
    fi
done
