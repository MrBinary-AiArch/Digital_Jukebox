#!/bin/bash
# ARM Watchdog Script (Enhanced with Abandon API)
# Detects and resets stuck rips (Logs silent for > 2 hours while disc is present)
# Add to root crontab: */30 * * * * /home/YOUR_USERNAME/scripts/arm_watchdog.sh >> /home/YOUR_USERNAME/reports/arm_watchdog.log 2>&1

# Configuration
LOG_DIR="/home/arm/logs"
MAX_IDLE_SECONDS=7200 # 2 Hours
DRIVES=("/dev/sr0" "/dev/sr1")
ARM_API="http://localhost:8080/json"

for DRIVE_DEV in "${DRIVES[@]}"; do
    # Check if disc exists via lsblk (size > 0)
    DISC_SIZE=$(lsblk -b -n -o SIZE $DRIVE_DEV | head -n 1)

    if [ -n "$DISC_SIZE" ] && [ "$DISC_SIZE" -gt 0 ] 2>/dev/null; then
        # Disc is present. Check logs.
        # Find latest log for this specific drive
        LATEST_LOG=$(grep -l "$DRIVE_DEV" "$LOG_DIR"/*.log 2>/dev/null | xargs ls -t 2>/dev/null | head -n 1)
        
        if [ -n "$LATEST_LOG" ]; then
            NOW=$(date +%s)
            FILE_MOD=$(stat -c %Y "$LATEST_LOG")
            DIFF=$((NOW - FILE_MOD))
            
            if [ $DIFF -gt $MAX_IDLE_SECONDS ]; then
                echo "[$(date)] STUCK RIP DETECTED on $DRIVE_DEV!"
                echo "  - Log: $LATEST_LOG"
                echo "  - Idle Time: $DIFF seconds"
                
                # Attempt to find the Job ID via the ARM API
                # We check failed/active jobs and filter by device path
                JOB_ID=$(curl -s "$ARM_API?mode=getfailed" | jq -r ".results[] | select(.devpath == \"$DRIVE_DEV\") | .job_id" | head -n 1)
                
                if [ -n "$JOB_ID" ] && [ "$JOB_ID" != "null" ]; then
                    echo "  - Action: Abandoning Job $JOB_ID via ARM API..."
                    curl -s "$ARM_API?mode=abandon&job=$JOB_ID" > /dev/null
                else
                    echo "  - Warning: Could not find Job ID for $DRIVE_DEV via API. Falling back to container restart."
                    docker restart arm
                fi
                
                # Wait for system to settle before ejecting
                sleep 10
                echo "  - Action: Ejecting $DRIVE_DEV..."
                eject "$DRIVE_DEV"
                
                echo "[$(date)] Reset Complete for $DRIVE_DEV."
                # Once we reset arm, we break out for this cycle
                break 
            else
                echo "[$(date)] Disc present in $DRIVE_DEV, but log is active (Idle: $DIFF seconds). No action."
            fi
        else
            echo "[$(date)] Disc present in $DRIVE_DEV, but no logs found mentioning this drive."
        fi
    fi
done
