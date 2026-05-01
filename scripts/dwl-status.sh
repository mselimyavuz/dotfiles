#!/bin/zsh

get_network() {
    # Ethernet Check
    local eth_devs=(/sys/class/net/enp*(N))
    local eth_status="down"
    if [[ ${#eth_devs} -gt 0 ]]; then
        for dev in $eth_devs; do
            if [[ -f "$dev/operstate" ]]; then
                eth_status=$(cat "$dev/operstate")
                [[ "$eth_status" == "up" ]] && break
            fi
        done
    fi

    if [[ "$eth_status" == "up" ]]; then
        echo "󰈀 Wired"
        return
    fi

    # Wi-Fi SSID from /proc or /sys
    local wifi_state=$(cat /sys/class/net/wlan0/operstate 2>/dev/null || echo "down")
    if [[ "$wifi_state" == "up" ]]; then
        # Try to get SSID from iwgetid, fallback to 'Connected'
        local ssid=$(iwgetid -r 2>/dev/null)
        
        # If iwgetid failed, try to get it from the 'iw' tool (more reliable on Gentoo)
        if [[ -z "$ssid" ]]; then
            ssid=$(iw dev wlan0 link | awk -F': ' '/SSID/ {print $2}')
        fi
        
        echo " ${ssid:-Connected}"
    else
        echo "󰤮 Disconnected"
    fi
}

get_zram() {
    awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END {if (t>0) printf "SW %.0f%%", ((t-f)/t)*100; else print "SW 0%"}' /proc/meminfo
}

get_temp() {
    local cpu=$(cat /sys/class/hwmon/hwmon5/temp1_input 2>/dev/null)
    local gpu=$(cat /sys/class/hwmon/hwmon5/temp2_input 2>/dev/null)
    local cpu_f=$(awk -v t="$cpu" 'BEGIN {if (t>0) printf "%.0f°C", t/1000; else print "N/A"}')
    local gpu_f=$(awk -v t="$gpu" 'BEGIN {if (t>0) printf "%.0f°C", t/1000; else print "RC6"}')
    echo " $cpu_f 󰢮 $gpu_f"
}

get_battery() {
    local cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")
    local stat=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    [[ "$stat" == "Charging" ]] && echo "󰂄 $cap%" || echo "󰁹 $cap%"
}

# Start background processes
(sleep 1 && pgrep -x swaybg > /dev/null || swaybg -i ~/workspace/main/WP/gentoo_wallpaper.png -m fill) &

while true; do
    echo " $(get_network) | $(get_zram) | $(get_temp) | $(get_battery) | $(date +'%Y-%m-%d %-I:%M %p') "
    sleep 5
done
