#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

export MONITOR=$(xrandr --query | grep " connected" | cut -d" " -f1 | head -n1)
polybar main &

