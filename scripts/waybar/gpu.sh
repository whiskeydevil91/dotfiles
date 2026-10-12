#!/usr/bin/env bash

# ------------------------------------------------------------
# gpu.sh
# Waybar module: GPU usage and temperature (AMD or NVIDIA).
# Bar text:  40% 61°C
# Class "hot" (pill turns pink) at 80°C, or on AMD when the
# hotspot gets within 10°C of the card's throttle point.
# ------------------------------------------------------------

set -euo pipefail

HOT_TEMP=80

output() {
    local text="$1" tooltip="$2" temp="$3" class="normal"
    [[ -n "$temp" && "$temp" -ge $HOT_TEMP ]] && class="hot"
    jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

# ------------------------------------------------------------
# NVIDIA
# ------------------------------------------------------------
if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null; then
    IFS=',' read -r NAME UTIL TEMP MEM_USED MEM_TOTAL POWER CLOCK < <(
        nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,clocks.gr \
            --format=csv,noheader,nounits | head -n 1
    )
    # Trim the spaces nvidia-smi puts after each comma
    UTIL=${UTIL// /}; TEMP=${TEMP// /}; CLOCK=${CLOCK// /}; POWER=${POWER// /}

    TOOLTIP="${NAME}
━━━━━━━━━━━━━━━━━━━━
Usage:       ${UTIL}%
Temperature: ${TEMP}°C
VRAM:        $(awk "BEGIN {printf \"%.1f / %.1f G\", $MEM_USED/1024, $MEM_TOTAL/1024}")
Clock:       ${CLOCK} MHz
Power:       ${POWER} W"

    output "${UTIL}% ${TEMP}°C" "$TOOLTIP" "$TEMP"
    exit 0
fi

# ------------------------------------------------------------
# AMD (amdgpu sysfs)
# hwmon channels: temp1 = edge, temp2 = junction (hotspot),
# temp3 = VRAM; temp2_crit is where the card starts throttling.
# ------------------------------------------------------------
read_sys() { cat "$1" 2>/dev/null || true; }

# Ryzen CPUs with built-in graphics expose a second amdgpu device.
# Use the one with the most VRAM, which is the graphics card.
DEV=""
BEST_VRAM=-1
for dev in /sys/class/drm/card[0-9]*/device; do
    [[ -f "$dev/gpu_busy_percent" ]] || continue
    vram=$(read_sys "$dev/mem_info_vram_total")
    if [[ ${vram:-0} -gt $BEST_VRAM ]]; then
        BEST_VRAM=${vram:-0}
        DEV="$dev"
    fi
done

if [[ -n "$DEV" ]]; then
    UTIL=$(read_sys "$DEV/gpu_busy_percent")
    HWMON=$(echo "$DEV"/hwmon/hwmon* | awk '{print $1}')

    # Name lookup is slow (lspci), so cache it for the session
    NAME_CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-gpu.name"
    if [[ ! -s "$NAME_CACHE" ]]; then
        NAME=$(read_sys "$DEV/product_name")
        if [[ -z "$NAME" ]]; then
            # "… [AMD/ATI] Navi 44 [Radeon RX 9060 XT] (rev c0)" → "Radeon RX 9060 XT"
            NAME=$(lspci -s "$(basename "$(readlink -f "$DEV")")" 2>/dev/null \
                | sed -E 's/.*: //; s/ \(rev [^)]*\)$//; s/.*\[([^]]*)\]$/\1/' || true)
        fi
        echo "${NAME:-AMD Radeon}" > "$NAME_CACHE"
    fi
    NAME=$(cat "$NAME_CACHE")

    # "68°C", or "n/a" when the sensor isn't there
    show() { [[ -n "$1" ]] && echo "$1°C" || echo "n/a"; }

    # millidegrees → °C, empty when the sensor isn't there
    temp() {
        local raw
        raw=$(read_sys "$HWMON/$1")
        [[ -n "$raw" ]] && echo $((raw / 1000))
        return 0
    }
    EDGE=$(temp temp1_input)
    JUNCTION=$(temp temp2_input)
    MEM_TEMP=$(temp temp3_input)
    THROTTLE=$(temp temp2_crit)

    FAN=$(read_sys "$HWMON/fan1_input")
    [[ -n "$FAN" ]] && FAN="$FAN RPM"
    CLOCK=$(read_sys "$HWMON/freq1_input")
    [[ -n "$CLOCK" ]] && CLOCK="$((CLOCK / 1000000)) MHz"

    # Newer kernels only provide power1_input on recent cards
    POWER=$(read_sys "$HWMON/power1_average")
    [[ -z "$POWER" ]] && POWER=$(read_sys "$HWMON/power1_input")
    CAP=$(read_sys "$HWMON/power1_cap")
    if [[ -n "$POWER" ]]; then
        POWER="$((POWER / 1000000)) W"
        [[ -n "$CAP" ]] && POWER+=" / $((CAP / 1000000)) W limit"
    fi

    VRAM=""
    USED=$(read_sys "$DEV/mem_info_vram_used")
    if [[ -n "$USED" && $BEST_VRAM -gt 0 ]]; then
        VRAM=$(awk -v u="$USED" -v t="$BEST_VRAM" 'BEGIN {printf "%.1f / %.1f G", u/1073741824, t/1073741824}')
    fi

    # Bar shows edge temp (what most tools call "GPU temperature")
    SHOWN=${EDGE:-$JUNCTION}
    TEXT="${UTIL:-0}%"
    [[ -n "$SHOWN" ]] && TEXT+=" ${SHOWN}°C"

    # Hot when edge reaches HOT_TEMP or the hotspot nears its throttle point
    CLASS="normal"
    [[ -n "$EDGE" && $EDGE -ge $HOT_TEMP ]] && CLASS="hot"
    if [[ -n "$JUNCTION" ]]; then
        LIMIT=$(( ${THROTTLE:-110} - 10 ))
        [[ $JUNCTION -ge $LIMIT ]] && CLASS="hot"
    fi

    TOOLTIP="${NAME}
━━━━━━━━━━━━━━━━━━━━
Usage:       ${UTIL:-0}%
Edge temp:   $(show "$EDGE")
Hotspot:     $(show "$JUNCTION") (throttles at $(show "$THROTTLE"))
VRAM temp:   $(show "$MEM_TEMP")
Fan:         ${FAN:-n/a}
Clock:       ${CLOCK:-n/a}
VRAM:        ${VRAM:-n/a}
Power:       ${POWER:-n/a}

Click to open nvtop"

    jq -nc --arg text "$TEXT" --arg tooltip "$TOOLTIP" --arg class "$CLASS" \
        '{text: $text, tooltip: $tooltip, class: $class}'
    exit 0
fi

output "n/a" "No GPU detected" ""
