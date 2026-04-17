#!/bin/env bash
AC_FILE=$(ls /sys/class/power_supply/AC*/online 2>/dev/null | head -n 1)

if [[ -n "$AC_FILE" ]] && grep -q "1" "$AC_FILE"; then
    # On AC: Keep screen on
    xset -dpms s off
else
    # On battery: Enable screensaver + DPMS
    xset s 300 600
    xset dpms 300 300 300
fi
