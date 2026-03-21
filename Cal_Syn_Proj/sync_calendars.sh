#!/bin/bash
# Calendar Sync Script for gcalsync
# This version uses Docker Compose for ease of use.

LOG_FILE="sync.log"

echo "------------------------------------------" >> $LOG_FILE
echo "$(date): Starting Sync..." >> $LOG_FILE

# Run the sync command using Docker Compose
# Assumes you are running this from the project directory.
docker compose run --rm gcalsync sync >> $LOG_FILE 2>&1

# Provide a quick summary in the log
BLOCKER_COUNT=$(grep -c "O_o" $LOG_FILE | tail -n 1)

echo "$(date): Sync Finished. (Found blocker events in log)" >> $LOG_FILE
