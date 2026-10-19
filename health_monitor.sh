
#!/bin/bash

ALERT_STATE="$HOME/linux-practice/.last_email_alert"

send_email_alert() {
    local subject="$1"
    local body="$2"
    local now
    local last=0

    now=$(date +%s)

    if [ -f "$ALERT_STATE" ]; then
        last=$(cat "$ALERT_STATE")
    fi

    # Suppress repeated email alerts for one hour.
    if [[ "$last" =~ ^[0-9]+$ ]] && (( now - last < 3600 )); then
        echo "Email alert suppressed: an alert was sent within the last hour."
        return
    fi

    if printf '%s\n' "$body" | python3 "$HOME/linux-practice/send_alert.py" --alert "$subject"; then
        echo "$now" > "$ALERT_STATE"
    else
        echo "ERROR: Email alert could not be sent."
    fi
}

echo "===== Health check started: $(date) ====="
echo ""
echo "================================"
echo "     LINUX SYSTEM HEALTH"
echo "================================"

echo ""
echo "DATE AND TIME"
date

echo ""
echo "MEMORY USAGE"
free -h

memory_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

echo ""
echo "MEMORY HEALTH CHECK"

if [ "$memory_usage" -ge 80 ]; then
    echo "WARNING: Memory usage is HIGH! ($memory_usage%)"
    echo "[$(date)] WARNING: Memory usage is HIGH! ($memory_usage%)" >> "$HOME/linux-practice/warnings.log"
    send_email_alert "Linux Health Monitor: High Memory Usage" "Memory usage is high: ${memory_usage}%"
else
    echo "OK: Memory usage is NORMAL. ($memory_usage%)"
fi

echo ""
echo "DISK USAGE"
df -h /

disk_usage=$(df / | tail -n 1 | awk '{print $5}' | tr -d '%')

echo ""
echo "DISK HEALTH CHECK"

if [ "$disk_usage" -ge 80 ]; then
    echo "WARNING: Disk usage is HIGH! ($disk_usage%)"
    echo "[$(date)] WARNING: Disk usage is HIGH! ($disk_usage%)" >> "$HOME/linux-practice/warnings.log"
    send_email_alert "Linux Health Monitor: High Disk Usage" "Disk usage is high: ${disk_usage}%"
else
    echo "OK: Disk usage is NORMAL. ($disk_usage%)"
fi

echo ""
echo "CPU AND SYSTEM LOAD"
uptime

cpu_idle=$(top -bn1 | awk -F',' '/Cpu\(s\)/ {for(i=1;i<=NF;i++) if($i ~ /id/) {gsub(/[^0-9.]/,"",$i); print $i}}')
cpu_usage=$(awk "BEGIN {printf \"%.0f\", 100 - $cpu_idle}")

echo ""
echo "CPU HEALTH CHECK"

if [ "$cpu_usage" -ge 80 ]; then
    echo "WARNING: CPU usage is HIGH! ($cpu_usage%)"
    echo "[$(date)] WARNING: CPU usage is HIGH! ($cpu_usage%)" >> "$HOME/linux-practice/warnings.log"
    send_email_alert "Linux Health Monitor: High CPU Usage" "CPU usage is high: ${cpu_usage}%"
else
    echo "OK: CPU usage is NORMAL. ($cpu_usage%)"
fi

echo ""
echo "================================"
echo "       HEALTH CHECK DONE"
echo "================================"


