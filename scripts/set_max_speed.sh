#!/bin/bash
# Wait for active ripping/encoding to finish
echo "Waiting for active CD ripping processes (abcde/cdparanoia) to finish..."

while pgrep -x "abcde" > /dev/null || pgrep -x "cdparanoia" > /dev/null; do
    # Check every 60 seconds
    sleep 60
done

echo "Ripping finished at $(date). Setting drives to maximum speed..."

# Set stable speed (12x) for both drives
sudo eject -x 12 /dev/sr0 2>/dev/null
sudo eject -x 12 /dev/sr1 2>/dev/null

echo "Drives /dev/sr0 and /dev/sr1 set to 12x speed for stability."
