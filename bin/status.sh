WEATHER_LOCATION="Brooklyn,NY"
BATTERY_LOW_THRESHOLD=20
VOLUME_HIGH_THRESHOLD=80
VOLUME_MED_THRESHOLD=40
MEDIA_TITLE_MAX_LENGTH=20
WEATHER_CACHE_FILE="/tmp/weather_cache"
WEATHER_CACHE_MAX_AGE=900

declare -A WEATHER_ICONS=(
  ["clear"]="☀️"
  ["sunny"]="☀️"
  ["partly cloudy"]="🌤"
  ["cloudy"]="☁️"
  ["overcast"]="☁️"
  ["light rain"]="🌧"
  ["rain"]="🌧"
  ["heavy rain"]="⛈"
  ["snow"]="❄️"
  ["light snow"]="🌨"
  ["fog"]="🌫️"
  ["mist"]="🌫️"
)

get_system_load() {
  awk '{printf "%.0f", ($1 / '$(nproc)') * 100}' /proc/loadavg
}

get_battery_icon() {
  local status="$1"
  local capacity="$2"
  local icon=""

  if [[ "$status" == "Charging" ]]; then
    icon="⚡"
  fi

  if [[ "$capacity" -ge $BATTERY_LOW_THRESHOLD ]]; then
    icon+="🔋:"
  else
    icon+="🪫:"
  fi
  echo "$icon"
}

get_battery_status() {
  local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
  local capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
  local health="N/A"

  if command -v upower &>/dev/null; then
    health=$(upower -i $(upower -e | grep BAT) | grep "capacity" | awk '{printf "%.0f", $2}' | sed 's/%//')
  fi

  echo "$status:$capacity:$health"
}

validate_weather_data() {
    local data="$1"
    [[ "$data" =~ [0-9°CF]+[[:space:]]+[[:alpha:]]+ ]]
}

get_weather_info() {
    local weather_data=""

    if [[ -f "$WEATHER_CACHE_FILE" ]] && [[ -s "$WEATHER_CACHE_FILE" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$WEATHER_CACHE_FILE")))
        if [[ $cache_age -lt $WEATHER_CACHE_MAX_AGE ]]; then
            weather_data=$(cat "$WEATHER_CACHE_FILE")
            if validate_weather_data "$weather_data"; then
                echo "$weather_data"
                return
            fi
        fi
    fi

    weather_data=$(curl -m 5 -s -f "https://wttr.in/$WEATHER_LOCATION?format=%t+%C&m")
    if [[ $? -eq 0 ]] && validate_weather_data "$weather_data"; then
        echo "$weather_data" > "$WEATHER_CACHE_FILE"
        echo "$weather_data"
    else
        if [[ -f "$WEATHER_CACHE_FILE" ]] && [[ -s "$WEATHER_CACHE_FILE" ]]; then
            weather_data=$(cat "$WEATHER_CACHE_FILE")
            if validate_weather_data "$weather_data"; then
                echo "$weather_data"
                return
            fi
        fi
        echo "N/A Unknown"
    fi
}

get_weather_icon() {
    local weather_desc="${1,,}"
    local icon="❓"

    for type in "${!WEATHER_ICONS[@]}"; do
        if [[ "$weather_desc" == *"$type"* ]]; then
            icon="${WEATHER_ICONS[$type]}"
            break
        fi
    done
    echo "$icon"
}

get_volume_info() {
  if ! command -v amixer &>/dev/null; then
    echo "N/A:[off]:❓"
    return
  fi

  local amixer_output=$(amixer get Master)
  local volume=$(echo "$amixer_output" | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')
  local status=$(echo "$amixer_output" | grep -oP '\[on\]|\[off\]' | head -1)
  local icon

  if [[ "$status" == "[off]" ]]; then
    icon="🔇"
  elif [[ "$volume" -ge $VOLUME_HIGH_THRESHOLD ]]; then
    icon="🔊"
  elif [[ "$volume" -ge $VOLUME_MED_THRESHOLD ]]; then
    icon="🔉"
  else
    icon="🔈"
  fi

  echo "$volume:$status:$icon"
}

get_media_status() {
  if ! command -v playerctl &>/dev/null; then
    echo "❓:No media playing"
    return
  fi

  local status=$(playerctl status 2>/dev/null || echo "No Player")
  local icon="❓"
  local title=$(playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null || echo "No media playing")

  case "$status" in
  "Playing") icon="▶️" ;;
  "Paused") icon="⏸️" ;;
  "Stopped") icon="⏹️" ;;
  esac

  if [[ ${#title} -gt $MEDIA_TITLE_MAX_LENGTH ]]; then
    title="${title:0:$((MEDIA_TITLE_MAX_LENGTH - 3))}..."
  fi

  echo "$icon:$title"
}

get_updates_count() {
  if command -v checkupdates &>/dev/null; then
    checkupdates 2>/dev/null | wc -l
  else
    echo "N/A"
  fi
}

get_gpu_info() {
  if command -v nvidia-smi &>/dev/null; then
    local gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader | sed 's/ %//')
    echo "${gpu_util}%"
  else
    echo "No GPU"
  fi
}

main() {
  local load_average=$(get_system_load)
  local gpu_info=$(get_gpu_info)
  local date_formatted=$(date "+%a, %b %d %Y, %-I:%M%P")

  IFS=':' read -r battery_status battery_capacity battery_health <<<"$(get_battery_status)"
  local battery_icon=$(get_battery_icon "$battery_status" "$battery_capacity")

  local updates_count=$(get_updates_count)

  local weather_data=$(get_weather_info)
  local weather_temp=$(echo "$weather_data" | awk '{print $1}')
  local weather_desc=$(echo "$weather_data" | awk '{$1=""; print $0}' | sed 's/^ *//')
  local weather_icon=$(get_weather_icon "$weather_desc")

  IFS=':' read -r volume volume_status volume_icon <<<"$(get_volume_info)"

  IFS=':' read -r media_icon media_title <<<"$(get_media_status)"

  echo "💻 ${load_average}% 🎮 ${gpu_info} ┆ $battery_icon$battery_capacity% 💊:$battery_health% ┆ 📦 $updates_count ┆ 🌡️ $weather_temp $weather_icon ┆ $volume_icon $volume% ┆ $media_icon $media_title ┆ 📅 $date_formatted ┆"
}

main
