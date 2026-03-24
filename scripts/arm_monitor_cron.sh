#!/bin/bash
# Wrapper for the ARM timeout monitor
# Centralized logging version

LOG_FILE="/home/mrbinary/projects/Digital_Jukebox/logs/arm_monitor.log"

{
    echo "--- Monitor Run: $(date) ---"
    cd "$(dirname "$0")"
    /usr/bin/python3 arm_timeout_monitor.py 30
    echo ""
} >> "$LOG_FILE" 2>&1
