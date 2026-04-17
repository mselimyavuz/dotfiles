#!/usr/bin/env bash

# 1. Check if the radio is soft-blocked or hard-blocked
# If it's NOT blocked, the radio is "On"
if rfkill list bluetooth | grep -q "blocked: no"; then
    
    # 2. Get the device name. We use 'info' on the connected devices 
    # because 'devices Connected' can be finicky without an active agent.
    # We grab the ID first, then get its Info Name.
    DEVICE_ID=$(bluetoothctl devices | grep "Device" | head -n 1 | cut -d ' ' -f 2)
    
    if [[ -n "$DEVICE_ID" ]]; then
        # Check if THIS specific device is actually connected
        IS_CONNECTED=$(bluetoothctl info "$DEVICE_ID" | grep "Connected: yes")
        if [[ -n "$IS_CONNECTED" ]]; then
            NAME=$(bluetoothctl info "$DEVICE_ID" | grep "Name:" | cut -d ' ' -f 2-)
            echo "󰂱 $NAME"
        else
            echo "󰂯 On"
        fi
    else
        echo "󰂯 On"
    fi
else
    echo "󰂲 Off"
fi

