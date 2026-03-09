#!/bin/bash
# ARM Watchdog Script
# Detects and resets stuck rips (Logs silent for > 2 hours while disc is present)
# Add to root crontab: */30 * * * * /root/scripts/arm_watchdog.sh >> /var/log/arm_watchdog.log 2>&1

# Configuration
LOG_DIR="/home/arm/logs"
MAX_IDLE_SECONDS=7200 # 2 Hours
DRIVES=("/dev/sr0" "/dev/sr1")

for DRIVE_DEV in "${DRIVES[@]}"; do
    DISC_SIZE=$(lsblk -b -n -o SIZE $DRIVE_DEV | head -n 1)

    if [ -n "$DISC_SIZE" ] && [ "$DISC_SIZE" -gt 0 ] 2>/dev/null; then
        LATEST_LOG=$(grep -l "$DRIVE_DEV" "$LOG_DIR"/*.log 2>/dev/null | xargs ls -t 2>/dev/null | head -n 1)
        
        if [ -n "$LATEST_LOG" ]; then
            NOW=$(date +%s)
            FILE_MOD=$(stat -c %Y "$LATEST_LOG")
            DIFF=$((NOW - FILE_MOD))
            
            if [ $DIFF -gt $MAX_IDLE_SECONDS ]; then
                echo "[$(date)] STUCK RIP DETECTED on $DRIVE_DEV!"
                docker restart arm
                sleep 15
                eject "$DRIVE_DEV"
                break 
            fi
        fi
    fi
done
