#!/bin/bash
# ARM Watchdog Script (Enhanced with Abandon API)
# Detects and resets stuck rips (Logs silent for > 2 hours while disc is present)
# Add to root crontab: */30 * * * * /home/mrbinary/scripts/arm_watchdog.sh >> /home/mrbinary/reports/arm_watchdog.log 2>&1

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
                # We check active jobs first, as these are the ones that can be "stuck"
                JOB_ID=$(curl -s "$ARM_API?mode=getactive" | jq -r ".results[]? | select(.devpath == \"$DRIVE_DEV\") | .job_id" | head -n 1)
                
                if [ -n "$JOB_ID" ] && [ "$JOB_ID" != "null" ]; then
                    echo "  - Action: Abandoning Active Job $JOB_ID via ARM API..."
                    curl -s "$ARM_API?mode=abandon&job=$JOB_ID" > /dev/null
                else
                    # If no active job, it's stuck at a lower level (udev/startup)
                    # Safety Check: Do not restart container if ANY drive has an active rip (using logic from check_rips.sh)
                    OTHER_ACTIVE=$(docker exec arm ps aux | grep -E "abcde|cdparanoia|makemkvcon|HandBrakeCLI" | grep -v grep)
                    
                    if [ -n "$OTHER_ACTIVE" ]; then
                        echo "  - Warning: Stuck state detected on $DRIVE_DEV, but OTHER drives are currently ripping."
                        echo "  - Action: Skipping container restart to protect active jobs. Will retry next cycle."
                        continue 
                    fi

                    echo "  - Warning: No active job ID found for $DRIVE_DEV and no other ripping activity detected."
                    echo "  - Action: Restarting ARM container to clear stuck hardware hook..."
                    docker restart arm
                    # Wait for container to fully come back before ejecting
                    sleep 20
                fi
                
                # Action: Ejecting the drive to stop the recurring detection
                echo "  - Action: Ejecting $DRIVE_DEV..."
                eject "$DRIVE_DEV" || sudo eject "$DRIVE_DEV"
                
                echo "[$(date)] Reset Complete for $DRIVE_DEV."
                # Once we reset arm, we break out for this cycle
                break 
            else
                # Optional: If idle > 30 mins but < 2 hours, we could log a warning but here we stay silent
                echo "[$(date)] Disc present in $DRIVE_DEV, but log is active (Idle: $DIFF seconds). No action."
            fi
        else
            echo "[$(date)] Disc present in $DRIVE_DEV, but no logs found mentioning this drive."
        fi
    fi
done
