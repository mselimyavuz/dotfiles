#!/bin/bash
if grep -q "1" /sys/class/power_supply/AC*/online; then
    # On AC: Keep screen on
    xset s off -dpms
else
    xset s 300 600
    xset dpms 300 450 600
fi

