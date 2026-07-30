#!/usr/bin/env bash

DIR="$(dirname "$0")"
player=$("$DIR/get-active-player.sh")

[ -z "$player" ] && exit 0

pos=$(playerctl -p "$player" position --format '{{ duration(position) }}' 2>/dev/null)
len=$(playerctl -p "$player" metadata --format '{{ duration(mpris:length) }}' 2>/dev/null)

if [ -z "$pos" ] || [ -z "$len" ]; then
    exit 0
fi

echo "$pos/$len"
