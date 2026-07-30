#!/usr/bin/env bash

DIR="$(dirname "$0")"
player=$("$DIR/get-active-player.sh")

[ -z "$player" ] && exit 0

playerctl -p "$player" metadata --format '{{ title }} - {{ artist }}' 2>/dev/null
