#!/usr/bin/env bash

WTTR=$(which wttrbar)
JQ=$(which jq)

if [[ -z "$WTTR" || -z "$JQ" ]]; then
    echo '{"text": "󰖐 Err", "tooltip": "Binaries not found"}'
    exit 1
fi

if OUTPUT=$($WTTR --location Istanbul --nerd --lang tr 2>/dev/null); then
    echo "$OUTPUT" | $JQ -c '
        .icon = (.text | split(" ")[0]) | 
        .text = .icon + " " + (
            (.tooltip | split("\n")[6] | split(" ")[2]) + " " + 
            (.tooltip | split("\n")[0] | gsub("<[^>]+>"; ""))
        )
    '
else
    echo '{"text": "󰖐 N/A", "tooltip": "Weather service unreachable"}'
fi

