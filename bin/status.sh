#!/bin/bash
get_battery_icon() {
  local status="$1"
  local capacity="$2"
  local icon=""
  if [[ "$status" == "Charging" ]]; then
    icon="⚡:✔️"
  else
    icon="⚡:🚫"
  fi
  if [[ "$capacity" -ge 20 ]]; then
    icon+=" 🔋:"
  else
    icon+=" 🪫:"
  fi
  echo "$icon"
}
load_average=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
date_formatted=$(date "+%a, %b %d %Y, %-I:%M%P")
battery_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
battery_icon=$(get_battery_icon "$battery_status" "$battery_capacity")
if command -v upower &>/dev/null; then
  battery_health=$(upower -i $(upower -e | grep BAT) | grep "capacity" | awk '{print $2}')
  battery_health=$(printf "%.0f" "$battery_health")
else
  battery_health="N/A"
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
    weather_desc=$(echo "$weather_desc" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//;s/ *$//')
    IFS=',' read -ra weather_types <<<"$weather_desc"
    for weather_type in "${weather_types[@]}"; do
      weather_type=$(echo "$weather_type" | sed 's/^ *//;s/ *$//')
      case "$weather_type" in
      "clear" | "sunny") weather_icon="☀️" ;;
      "partly cloudy") weather_icon="🌤" ;;
      "cloudy" | "overcast") weather_icon="☁️" ;;
      "light rain" | "rain") weather_icon="🌧" ;;
      "heavy rain") weather_icon="⛈" ;;
      "snow") weather_icon="❄️" ;;
      "light snow") weather_icon="🌨" ;;
      "fog" | "mist") weather_icon="🌫️" ;;
      *) weather_icon="❓" ;;
      esac
    done
  fi
fi
if command -v amixer &>/dev/null; then
  volume=$(amixer get Master | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')
  volume_status=$(amixer get Master | grep -oP '\[on\]|\[off\]' | head -1)
  if [[ "$volume_status" == "[off]" ]]; then
    volume_icon="🔇"
  else
    if [[ "$volume" -ge 80 ]]; then
      volume_icon="🔊"
    elif [[ "$volume" -ge 40 ]]; then
      volume_icon="🔉"
    else
      volume_icon="🔈"
    fi
  fi
else
  volume="N/A"
  volume_icon="❓"
fi
if command -v playerctl &>/dev/null; then
  media_status=$(playerctl status 2>/dev/null || echo "No Player")
  if [[ "$media_status" == "Playing" ]]; then
    media_icon="▶️"
  elif [[ "$media_status" == "Paused" ]]; then
    media_icon="⏸️"
  elif [[ "$media_status" == "Stopped" ]]; then
    media_icon="⏹️"
  else
    media_icon="❓"
  fi
  media_title=$(playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null || echo "No media playing")
  if [[ ${#media_title} -gt 20 ]]; then
    media_title="${media_title:0:17}..."
  fi
  media_output="$media_icon $media_title"
else
  media_output="🎵 No media playing"
fi
echo "📊 $load_average ┆ $battery_icon$battery_capacity% 💊:$battery_health% ┆ 📦 $updates_count ┆ 🌡️ $weather_temp $weather_icon ┆ $volume_icon $volume% ┆ $media_output ┆ 📅 $date_formatted ┆"
