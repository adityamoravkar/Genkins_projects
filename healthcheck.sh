#!/bin/bash

# AlmaLinux 9 System Health Check Script
# It is recommended to run this script with sudo or as root.

echo "==============================================="
echo "       AlmaLinux 9 System Health Report        "
echo "==============================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "OS Release: $(cat /etc/almalinux-release)"
echo "==============================================="

echo -e "\n--- 1. UPTIME & LOAD AVERAGE ---"
uptime

echo -e "\n--- 2. MEMORY USAGE ---"
free -h

echo -e "\n--- 3. CPU USAGE ---"
# Extracts CPU usage from the top command
top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2 "% user, " $4 "% system, " $8 "% idle"}'

echo -e "\n--- 4. DISK SPACE USAGE ---"
# Shows disk usage, filtering out temporary file systems for clarity
df -hT | grep -vE '^tmpfs|devtmpfs' | awk '{print $1 " \t " $6 " \t " $7}' | column -t

echo -e "\n--- 5. FAILED SYSTEMD SERVICES ---"
# Checks for any system services that have crashed or failed to start
FAILED_SERVICES=$(systemctl list-units --state=failed --no-legend)
if [ -z "$FAILED_SERVICES" ]; then
    echo "All services are running normally. No failed services."
else
    echo "$FAILED_SERVICES"
fi

echo -e "\n--- 6. CRITICAL SYSTEM ERRORS (Since last boot) ---"
# Pulls the last 5 critical/error logs from the systemd journal
journalctl -p 3 -xb -q | tail -5

echo -e "\n--- 7. RECENT LOGINS ---"
# Shows the last 5 users who logged into the system
last -a | head -5

echo -e "\n==============================================="
echo "                END OF REPORT                  "
echo "==============================================="
