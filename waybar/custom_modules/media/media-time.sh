#!/usr/bin/env bash

DIR="$(dirname "$0")"
STATE_FILE="/tmp/waybar-media-time-state"
SEP=$'\x1f'

IFS=$'\t' read -r player status <<< "$("$DIR/get-active-player.sh")"

if [ -z "$player" ]; then
    rm -f "$STATE_FILE"
    exit 0
fi

now=$(date +%s.%N)

title=$(playerctl -p "$player" metadata title 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
length_us=$(playerctl -p "$player" metadata mpris:length 2>/dev/null)
raw_pos=$(playerctl -p "$player" position 2>/dev/null)   # already in SECONDS - do not divide

length=""
[ -n "$length_us" ] && length=$(awk "BEGIN{printf \"%.4f\", $length_us/1000000}")

prev_player=""; prev_title=""; prev_artist=""; prev_pos=""; prev_ts=""; prev_length=""; prev_status=""
if [ -f "$STATE_FILE" ]; then
    IFS="$SEP" read -r prev_player prev_title prev_artist prev_pos prev_ts prev_length prev_status < "$STATE_FILE"
fi

if [ -n "$raw_pos" ]; then
    # Trust the real position whenever the player gives us one - this is
    # what keeps the display in sync with actual playback, seeks, and
    # switching between different sources.
    base_pos="$raw_pos"
else
    # Player didn't answer this specific tick - bridge the gap by
    # extrapolating from the last known position instead of showing
    # nothing. Self-corrects the moment a real reading comes back.
    same_track=false
    if [ "$player" = "$prev_player" ] && [ "$title" = "$prev_title" ] && [ "$artist" = "$prev_artist" ]; then
        same_track=true
    fi
    if $same_track && [ -n "$prev_pos" ]; then
        if [ "$status" = "Playing" ]; then
            elapsed=$(awk "BEGIN{print $now - $prev_ts}")
            base_pos=$(awk "BEGIN{printf \"%.4f\", $prev_pos + $elapsed}")
        else
            base_pos="$prev_pos"
        fi
    else
        base_pos="0"
    fi
fi

[ -z "$length" ] && length="$prev_length"

if [ -n "$length" ] && awk "BEGIN{exit !($base_pos > $length)}" 2>/dev/null; then
    base_pos="$length"
fi

printf "%s%s%s%s%s%s%s%s%s%s%s%s%s\n" \
    "$player" "$SEP" "$title" "$SEP" "$artist" "$SEP" "$base_pos" "$SEP" "$now" "$SEP" "$length" "$SEP" "$status" \
    > "$STATE_FILE"

fmt_time() {
    local secs=$1
    if [ -z "$secs" ]; then
        echo "0:00"
        return
    fi
    # Round to the nearest second instead of truncating - truncation was
    # what made every track display ~1s short of its real length.
    secs=$(printf '%.0f' "$secs")
    local h=$((secs/3600))
    local m=$(((secs%3600)/60))
    local s=$((secs%60))
    if [ "$h" -gt 0 ]; then
        printf "%d:%02d:%02d" "$h" "$m" "$s"
    else
        printf "%d:%02d" "$m" "$s"
    fi
}

pos_fmt=$(fmt_time "$base_pos")
len_fmt=$(fmt_time "$length")

echo "$pos_fmt/$len_fmt"
