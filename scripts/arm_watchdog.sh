#!/bin/bash
# ARM Watchdog Script (Enhanced with Abandon API and Database Awareness)
# Detects and resets stuck rips (Logs silent for > 2 hours while disc is present)
# Add to root crontab: */30 * * * * /home/mrbinary/projects/Digital_Jukebox/scripts/arm_watchdog.sh >> /home/mrbinary/reports/arm_watchdog.log 2>&1

# Configuration
LOG_DIR="/home/arm/logs"
MAX_IDLE_SECONDS=7200 # 2 Hours
DRIVES=("/dev/sr0" "/dev/sr1")
ARM_API="http://localhost:8080/json"
ARM_DB="/home/arm/db/arm.db"

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
                
                # Check ARM Database to see if this log is already marked as completed
                LOG_FILENAME=$(basename "$LATEST_LOG")
                JOB_STATUS=$(sqlite3 "$ARM_DB" "SELECT status FROM job WHERE logfile = '$LOG_FILENAME' ORDER BY job_id DESC LIMIT 1;" 2>/dev/null)
                
                if [[ "$JOB_STATUS" == "success" || "$JOB_STATUS" == "fail" || "$JOB_STATUS" == "completed" || "$JOB_STATUS" == "failed" ]]; then
                    echo "  - Note: Job for this log is already marked as '$JOB_STATUS' in the database."
                    echo "  - Action: Attempting Eject ONLY. Skipping container restart to avoid loop."
                    eject "$DRIVE_DEV" || sudo eject "$DRIVE_DEV"
                    continue
                fi

                # Attempt to find the Job ID via the ARM API
                JOB_ID=$(curl -s "$ARM_API?mode=getactive" | jq -r ".results[]? | select(.devpath == \"$DRIVE_DEV\") | .job_id" | head -n 1)
                
                if [ -n "$JOB_ID" ] && [ "$JOB_ID" != "null" ]; then
                    echo "  - Action: Abandoning Active Job $JOB_ID via ARM API..."
                    curl -s "$ARM_API?mode=abandon&job=$JOB_ID" > /dev/null
                else
                    # Safety Check: Do not restart container if ANY drive has an active rip
                    OTHER_ACTIVE=$(docker exec arm ps aux | grep -E "abcde|cdparanoia|makemkvcon|HandBrakeCLI" | grep -v grep)
                    
                    if [ -n "$OTHER_ACTIVE" ]; then
                        echo "  - Warning: Stuck state detected on $DRIVE_DEV, but OTHER drives are currently ripping."
                        echo "  - Action: Skipping container restart to protect active jobs. Will retry next cycle."
                        continue 
                    fi

                    echo "  - Warning: No active job ID found for $DRIVE_DEV and no other ripping activity detected."
                    echo "  - Action: Restarting ARM container to clear stuck hardware hook..."
                    docker restart arm
                    sleep 20
                fi
                
                # Action: Ejecting the drive
                echo "  - Action: Ejecting $DRIVE_DEV..."
                eject "$DRIVE_DEV" || sudo eject "$DRIVE_DEV"
                
                echo "[$(date)] Reset Complete for $DRIVE_DEV."
                break 
            else
                echo "[$(date)] Disc present in $DRIVE_DEV, but log is active (Idle: $DIFF seconds). No action."
            fi
        else
            echo "[$(date)] Disc present in $DRIVE_DEV, but no logs found mentioning this drive."
        fi
    fi
done
