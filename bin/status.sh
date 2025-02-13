#!/bin/bash

uptime_formatted=$(uptime -p | sed 's/up //')
load_average=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
date_formatted=$(date "+%a, %b %d %Y, %-I:%M%P")
linux_version=$(uname -r | awk -F '-' '{print $1}')
battery_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")

if [[ "$battery_status" == "Charging" ]]; then
  battery_icon="🔌"
else
  if [[ "$battery_capacity" -ge 80 ]]; then
    battery_icon="🔋"
  elif [[ "$battery_capacity" -ge 60 ]]; then
    battery_icon="🔋"
  elif [[ "$battery_capacity" -ge 40 ]]; then
    battery_icon="🔋"
  elif [[ "$battery_capacity" -ge 20 ]]; then
    battery_icon="🔋"
  else
    battery_icon="🪫"
  fi
fi

if command -v checkupdates &>/dev/null; then
  updates_count=$(checkupdates 2>/dev/null | wc -l)
else
  updates_count="N/A"
fi

weather_icon="❓"
weather_temp="N/A"

if command -v curl &>/dev/null; then
  weather_data=$(curl -s "https://wttr.in/Brooklyn,NY?format=%t+%C&m")
  if [[ -n "$weather_data" ]]; then
    weather_temp=$(echo "$weather_data" | awk '{print $1}')
    weather_desc=$(echo "$weather_data" | awk '{$1=""; print $0}' | sed 's/^ *//')
    case "$weather_desc" in
    "Clear" | "Sunny") weather_icon="☀️" ;;
    "Partly cloudy") weather_icon="🌤" ;;
    "Cloudy" | "Overcast") weather_icon="☁️" ;;
    "Light rain" | "Rain") weather_icon="🌧" ;;
    "Heavy rain") weather_icon="⛈" ;;
    "Snow" | "Light snow") weather_icon="❄️" ;;
    "Fog" | "Mist") weather_icon="🌫" ;;
    *) weather_icon="❓" ;;
    esac
  fi
fi

uptime_icon="⏳"
linux_icon="🐧"
date_icon="📅"
updates_icon="📦"
weather_icon_label="🌡️"
load_icon="📊"

echo "$uptime_icon $uptime_formatted | $load_icon $load_average | $linux_icon $linux_version | $battery_icon $battery_status ($battery_capacity%) | $updates_icon $updates_count updates | $weather_icon_label $weather_temp $weather_icon | $date_icon $date_formatted |"
