#!/bin/bash
set -e
set -u

ALERT_THRESHOLD_PCENT=10

battery_info="$(cat /sys/class/power_supply/BAT0/uevent)"
battery_status="$(cat /sys/class/power_supply/BAT0/status)"

function getRead() {
	echo $(echo "$battery_info" | grep "$1" | awk '{split($0,a,"="); print a[2]}')
}

battery_now=$(getRead POWER_SUPPLY_ENERGY_NOW)
battery_capacity=$(getRead POWER_SUPPLY_ENERGY_FULL_DESIGN)

battery_full_pcent=$(( $battery_now * 100 / $battery_capacity ))

if [[ $battery_full_pcent -lt $ALERT_THRESHOLD_PCENT && "$battery_status" != "Charging" ]]
then
    DISPLAY=':0' DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/1000/bus' /usr/bin/notify-send -t 5000 -u critical "CHARGE NOW" "Battery at ${battery_full_pcent}%"
fi

