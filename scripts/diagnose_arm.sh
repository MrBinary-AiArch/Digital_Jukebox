#!/bin/bash
# ARM Diagnosis Script v2
# Usage: sudo ./diagnose_arm.sh

echo "=== 1. System Uptime & Time ==="
uptime
date

echo -e "\n=== 2. Checking Optical Drive Status ==="
for DRIVE in /dev/sr0 /dev/sr1; do
    if [ -e "$DRIVE" ]; then
        echo "Drive $DRIVE DETECTED."
        lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$DRIVE"
    else
        echo "CRITICAL: Drive $DRIVE NOT DETECTED by OS."
    fi
done

echo -e "\n=== 3. Checking ARM Container Status ==="
docker ps --filter "name=arm" --format "table {{.Names}}\t{{.Status}}\t{{.State}}"

echo -e "\n=== 4. Checking for Active Ripping Processes ==="
# Check inside container for actual work
OTHER_ACTIVE=$(docker exec arm ps aux | grep -E "abcde|cdparanoia|makemkvcon|HandBrakeCLI" | grep -v grep)
if [ -n "$OTHER_ACTIVE" ]; then
    echo "Ripping process(es) ACTIVE inside container:"
    echo "$OTHER_ACTIVE"
else
    echo "No active ripping processes found (Idle)."
fi

echo -e "\n=== 5. Checking ARM Database for Ghost Jobs ==="
DB_PATH="/home/arm/db/arm.db"
if [ -f "$DB_PATH" ]; then
    GHOSTS=$(sqlite3 "$DB_PATH" "SELECT job_id, devpath, start_time FROM job WHERE stop_time IS NULL OR stop_time = '';" 2>/dev/null)
    if [ -n "$GHOSTS" ]; then
        echo "WARNING: Active (Ghost) jobs detected in database with no stop_time:"
        echo "$GHOSTS"
    else
        echo "Database check: No ghost jobs found."
    fi
else
    echo "ARM Database not found at $DB_PATH."
fi

echo -e "\n=== 6. Checking ARM Log Files (Host) ==="
# Based on docker-compose, logs are at /home/arm/logs
LOG_DIR="/home/arm/logs"
BOOT_TIME=$(stat -c %Y /proc/1)

if [ -d "$LOG_DIR" ]; then
    for DRIVE in /dev/sr0 /dev/sr1; do
        LATEST_LOG=$(grep -l "$DRIVE" "$LOG_DIR"/*.log 2>/dev/null | xargs ls -t 2>/dev/null | head -n 1)
        if [ -n "$LATEST_LOG" ]; then
            FILE_MOD=$(stat -c %Y "$LATEST_LOG")
            echo "Latest log for $DRIVE: $LATEST_LOG"
            echo "Modified: $(date -d "@$FILE_MOD")"
            if [ $FILE_MOD -lt $BOOT_TIME ]; then
                echo "  -> NOTE: This log is from a PREVIOUS boot session (STALE)."
            fi
            echo "Last 5 lines:"
            tail -n 5 "$LATEST_LOG"
            echo "-------------------"
        fi
    done
else
    echo "Log directory $LOG_DIR not found on host."
fi