#!/bin/bash

# Path to the ARM database
DB_PATH="/home/arm/db/arm.db"

echo "--- Checking ARM Database for active jobs ---"
# Query for jobs that are not in a final state
ACTIVE_JOBS=$(sqlite3 "$DB_PATH" "SELECT job_id, title, devpath, status FROM job WHERE status NOT IN ('completed', 'fail', 'success')" 2>/dev/null)

if [ -z "$ACTIVE_JOBS" ]; then
    echo "No active jobs found in database."
else
    echo "Active jobs found:"
    echo "$ACTIVE_JOBS"
fi

echo ""
echo "--- Checking for active ripping processes in container ---"
# Check for known ripping processes inside the container
ACTIVE_PROCS=$(docker exec arm ps aux | grep -E "abcde|cdparanoia|makemkvcon|HandBrakeCLI" | grep -v grep)

if [ -z "$ACTIVE_PROCS" ]; then
    echo "No active ripping processes detected."
else
    echo "Active processes detected:"
    echo "$ACTIVE_PROCS"
fi

if [ -z "$ACTIVE_JOBS" ] && [ -z "$ACTIVE_PROCS" ]; then
    echo ""
    echo "SAFE TO RESTART: No ripping activity detected."
    exit 0
else
    echo ""
    echo "!!! DO NOT RESTART: Ripping activity detected !!!"
    exit 1
fi
