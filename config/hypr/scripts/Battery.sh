#!/bin/bash
BAT=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)
if [ "$STATUS" = "Charging" ]; then
    echo "${BAT}%"
else
    echo "${BAT}%"
fi
