#!/usr/bin/env bash

# ------------------------------------------------------------
# cpu.sh
# Waybar module: current CPU usage and temperature.
# Bar text:  23% 54°C
# Class "hot" at 90°C or above (pill turns pink). Modern Ryzen
# and Intel CPUs run up to ~95°C under load by design, so lower
# thresholds would flag normal gaming.
# ------------------------------------------------------------

set -euo pipefail

HOT_TEMP=90
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu.stat"

# ------------------------------------------------------------
# Usage since the last run (Waybar calls this every 2s)
# ------------------------------------------------------------
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
IDLE=$((idle + iowait))
TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))

USAGE=0
if [[ -f "$STATE_FILE" ]]; then
    read -r PREV_IDLE PREV_TOTAL < "$STATE_FILE"
    DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
    DIFF_IDLE=$((IDLE - PREV_IDLE))
    if [[ $DIFF_TOTAL -gt 0 ]]; then
        USAGE=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL ))
    fi
fi
echo "$IDLE $TOTAL" > "$STATE_FILE"

# ------------------------------------------------------------
# Temperature: AMD (k10temp) or Intel (coretemp) via sysfs
# ------------------------------------------------------------
TEMP=""
for hwmon in /sys/class/hwmon/hwmon*; do
    case "$(cat "$hwmon/name" 2>/dev/null)" in
        k10temp|coretemp|zenpower)
            # temp1 is Tctl (AMD) or Package (Intel)
            if [[ -f "$hwmon/temp1_input" ]]; then
                TEMP=$(( $(cat "$hwmon/temp1_input") / 1000 ))
                break
            fi
            ;;
    esac
done

# ------------------------------------------------------------
# Tooltip details
# ------------------------------------------------------------
MODEL=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)
FREQ=$(awk -F': ' '/cpu MHz/ {sum += $2; n++} END {if (n) printf "%.2f", sum / n / 1000}' /proc/cpuinfo)
LOAD=$(cut -d' ' -f1-3 /proc/loadavg)
TOP=$(ps -eo comm,%cpu --sort=-%cpu --no-headers | head -n 5 | awk '{printf "  %-18s %5.1f%%\n", $1, $2}')

TEXT="${USAGE}%"
CLASS="normal"
if [[ -n "$TEMP" ]]; then
    TEXT+=" ${TEMP}°C"
    [[ $TEMP -ge $HOT_TEMP ]] && CLASS="hot"
fi

TOOLTIP="${MODEL}
━━━━━━━━━━━━━━━━━━━━
Usage:       ${USAGE}%
Temperature: ${TEMP:-n/a}°C
Clock:       ${FREQ:-n/a} GHz
Load:        ${LOAD}

Top processes
${TOP}

Click to open btop"

jq -nc --arg text "$TEXT" --arg tooltip "$TOOLTIP" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
