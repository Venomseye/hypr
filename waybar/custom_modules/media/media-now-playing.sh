#!/usr/bin/env bash

DIR="$(dirname "$0")"

zscroll -l 20 \
    --delay 0.3 \
    --update-check true \
    "$DIR/media-now-playing-info.sh" | "$DIR/media-now-playing-wrap.sh"
