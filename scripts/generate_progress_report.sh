#!/bin/bash
# Digital <YOUR_HOSTNAME> Progress Report
# Generates a summary of system health, storage, and library statistics.

# Configuration
PLEX_DB="/home/<YOUR_USER>/docker/plex/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
STORAGE_DIR="/mnt/storage"
MUSIC_LIB="/mnt/storage/music/library"
LOG_FILE="/home/<YOUR_USER>/projects/Digital_<YOUR_HOSTNAME>/logs/progress_report.log"
export TZ="America/Chicago"

{
echo "--------------------------------------------------"
echo "🎵 <YOUR_HOSTNAME> PROGRESS REPORT: $(date '+%Y-%m-%d %H:%M')"
echo "--------------------------------------------------"
echo ""

# Calculate Rip Counts
COUNT_24H=$(find "$MUSIC_LIB" -mindepth 2 -maxdepth 2 -type d -mtime -1 2>/dev/null | wc -l)
COUNT_7D=$(find "$MUSIC_LIB" -mindepth 2 -maxdepth 2 -type d -mtime -7 2>/dev/null | wc -l)
COUNT_30D=$(find "$MUSIC_LIB" -mindepth 2 -maxdepth 2 -type d -mtime -30 2>/dev/null | wc -l)

echo "Great job! In the last..."
echo "  • 24 Hours:  $COUNT_24H CDs"
echo "  • 7 Days:    $COUNT_7D CDs"
echo "  • 30 Days:   $COUNT_30D CDs"
echo ""

echo "💿 Ripped in Last 24 Hours:"
if [ "$COUNT_24H" -eq 0 ]; then
    echo "  (No new rips detected)"
else
    find "$MUSIC_LIB" -mindepth 2 -maxdepth 2 -type d -mtime -1 -printf "  • %f\n" 2>/dev/null
fi
echo ""

echo "--------------------------------------------------"
echo "📊 SYSTEM HEALTH"
echo "--------------------------------------------------"
echo "• Uptime: $(uptime -p)"
echo "• Storage: $(df -h "$STORAGE_DIR" | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"

if pgrep -x "HandBrakeCLI" > /dev/null || pgrep -x "makemkvcon" > /dev/null; then
    echo "• Status:  ⚠️  Active Ripping in Progress"
else
    echo "• Status:  ✅  Idle"
fi
echo ""

echo "--------------------------------------------------"
echo "🎧 LIBRARY TOTALS"
echo "--------------------------------------------------"

if [ -f "$PLEX_DB" ]; then
    python3 <<PYEOF
import sqlite3
import datetime
import os

db_path = "$PLEX_DB"
try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*), SUM(duration) FROM media_items WHERE duration > 0")
    row = cursor.fetchone()
    total_tracks = row[0] if row[0] else 0
    total_duration_ms = row[1] if row[1] else 0
    total_seconds = total_duration_ms / 1000
    td = datetime.timedelta(seconds=total_seconds)
    days = td.days
    hours = td.seconds // 3600
    minutes = (td.seconds // 60) % 60
    print(f"  • Total Tracks:    {total_tracks}")
    print(f"  • Total Play Time: {days} days, {hours} hours, {minutes} minutes")
    conn.close()
except Exception as e:
    print(f"  Error querying Plex DB: {e}")
PYEOF
else
    echo "  Error: Plex Database not found."
fi

echo ""
echo "--------------------------------------------------"
echo -e "\n"
} >> "$LOG_FILE" 2>&1

if [ -t 1 ]; then
    tail -n 60 "$LOG_FILE"
fi
