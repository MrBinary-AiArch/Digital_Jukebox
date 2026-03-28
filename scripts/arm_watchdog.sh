#!/bin/bash
# ARM Watchdog Script (v3 - Reliability & Self-Healing)
# Detects and resets stuck rips + automatically prunes failed database entries.
# Add to root crontab: */30 * * * * /home/<YOUR_USER>/scripts/arm_watchdog.sh >> /home/<YOUR_USER>/reports/arm_watchdog.log 2>&1

# Configuration
LOG_DIR="/home/arm/logs"
MAX_IDLE_SECONDS=7200 # 2 Hours
DRIVES=("/dev/sr0" "/dev/sr1")
ARM_API="http://localhost:8080/json"
DB_PATH="/home/arm/db/arm.db"

# --- Database Sanity Check & Pruning ---
# 1. Clear any 'current job' links in system_drives if the job has failed.
# 2. Delete all records for failed jobs older than 10 minutes to keep the database clean.
# This prevents "Ghost Jobs" and "Sticky Metadata" from blocking the system.
echo "[$(date)] Running Database Sanity Check & Pruning..."

# Clear drive mapping links for any currently failed jobs
sqlite3 "$DB_PATH" "UPDATE system_drives SET job_id_current=NULL WHERE job_id_current IN (SELECT job_id FROM job WHERE status='fail');"

# Identify and Purge failed jobs older than 10 minutes
FAILED_JOBS=$(sqlite3 "$DB_PATH" "SELECT job_id FROM job WHERE status='fail' AND stop_time < datetime('now', '-10 minutes');")
if [ -n "$FAILED_JOBS" ]; then
    echo "  - Found failed jobs: $FAILED_JOBS. Pruning from database..."
    sqlite3 "$DB_PATH" "DELETE FROM track WHERE job_id IN (SELECT job_id FROM job WHERE status='fail' AND stop_time < datetime('now', '-10 minutes'));"
    sqlite3 "$DB_PATH" "DELETE FROM config WHERE job_id IN (SELECT job_id FROM job WHERE status='fail' AND stop_time < datetime('now', '-10 minutes'));"
    sqlite3 "$DB_PATH" "DELETE FROM job WHERE status='fail' AND stop_time < datetime('now', '-10 minutes');"
fi

# Standard Ghost Job check (marking successful/completed jobs as ejected)
GHOST_JOBS=$(sqlite3 "$DB_PATH" "SELECT job_id FROM job WHERE ejected=0 AND status IN ('success', 'completed') AND stop_time < datetime('now', '-10 minutes');")
if [ -n "$GHOST_JOBS" ]; then
    echo "  - Found ghost successful jobs: $GHOST_JOBS. Marking as ejected..."
    sqlite3 "$DB_PATH" "UPDATE job SET ejected=1 WHERE ejected=0 AND status IN ('success', 'completed') AND stop_time < datetime('now', '-10 minutes');"
fi

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
            BOOT_TIME=$(stat -c %Y /proc/1)
            DIFF=$((NOW - FILE_MOD))
            
            # Check if log is older than current boot session
            if [ $FILE_MOD -lt $BOOT_TIME ]; then
                echo "[$(date)] Latest log for $DRIVE_DEV ($LATEST_LOG) is from a previous boot session. Ignoring."
                continue
            fi
            
            if [ $DIFF -gt $MAX_IDLE_SECONDS ]; then
                echo "[$(date)] STUCK RIP DETECTED on $DRIVE_DEV!"
                echo "  - Log: $LATEST_LOG"
                echo "  - Idle Time: $DIFF seconds"
                
                # Check ARM Database to see if this log is already marked as completed
                LOG_FILENAME=$(basename "$LATEST_LOG")
                JOB_STATUS=$(sqlite3 /home/arm/db/arm.db "SELECT status FROM job WHERE logfile = '$LOG_FILENAME' ORDER BY job_id DESC LIMIT 1;" 2>/dev/null)
                
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
