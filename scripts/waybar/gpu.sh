#!/usr/bin/env bash

# ------------------------------------------------------------
# gpu.sh
# Waybar module: GPU usage and temperature (NVIDIA or AMD).
# Bar text:  40% 61°C
# Class "hot" at 80°C or above (pill turns pink).
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
if command -v nvidia-smi &>/dev/null; then
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
# ------------------------------------------------------------
for dev in /sys/class/drm/card[0-9]*/device; do
    [[ -f "$dev/gpu_busy_percent" ]] || continue

    UTIL=$(cat "$dev/gpu_busy_percent")
    NAME=$(cat "$dev/product_name" 2>/dev/null || echo "AMD Radeon")

    HWMON=$(echo "$dev"/hwmon/hwmon* | awk '{print $1}')
    TEMP=""
    [[ -f "$HWMON/temp1_input" ]] && TEMP=$(( $(cat "$HWMON/temp1_input") / 1000 ))
    JUNCTION=""
    [[ -f "$HWMON/temp2_input" ]] && JUNCTION=$(( $(cat "$HWMON/temp2_input") / 1000 ))
    POWER=""
    for f in "$HWMON/power1_average" "$HWMON/power1_input"; do
        [[ -f "$f" ]] && { POWER=$(( $(cat "$f") / 1000000 )); break; }
    done

    VRAM="n/a"
    if [[ -f "$dev/mem_info_vram_used" ]]; then
        VRAM=$(awk -v u="$(cat "$dev/mem_info_vram_used")" -v t="$(cat "$dev/mem_info_vram_total")" \
            'BEGIN {printf "%.1f / %.1f G", u/1073741824, t/1073741824}')
    fi

    TOOLTIP="${NAME}
━━━━━━━━━━━━━━━━━━━━
Usage:       ${UTIL}%
Temperature: ${TEMP:-n/a}°C (junction ${JUNCTION:-n/a}°C)
VRAM:        ${VRAM}
Power:       ${POWER:-n/a} W"

    TEXT="${UTIL}%"
    [[ -n "$TEMP" ]] && TEXT+=" ${TEMP}°C"
    output "$TEXT" "$TOOLTIP" "$TEMP"
    exit 0
done

output "n/a" "No GPU detected" ""
