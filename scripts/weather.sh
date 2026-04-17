#!/usr/bin/env bash

WTTR="$HOME/.local/bin/wttrbar"
JQ=$(which jq)

if [[ ! -x "$WTTR" || -z "$JQ" ]]; then
    echo "󰖐 Err"
    exit 1
fi

$WTTR --location Istanbul --nerd --lang tr 2>/dev/null | $JQ -r '
    (.text | split(" ")[0]) + " " + 
    (.text | split(" ")[1]) + "°C " + 
    (.tooltip | split("\n")[0] | gsub("<[^>]+>"; ""))
' | sed 's/ [0-9]*°$//'
