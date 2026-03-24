#!/bin/bash
# Manual Rip Trigger for Audio CDs
# Usage: sudo ./manual_rip.sh

echo "=== Manual Rip Initiated ==="
echo "Target: /dev/sr0 (Audio CD)"
echo "Method: Direct 'abcde' execution inside ARM container"

# Check if container is running
if [ "$(docker inspect -f '{{.State.Running}}' arm)" = "true" ]; then
    echo "Container is running. Proceeding..."
else
    echo "Container is stopped. Starting it..."
    docker start arm
    sleep 5
fi

# Execute rip
# Using the specific command that worked previously
# -d: Device
# -c: Config file
# -N: Non-interactive
# -x: Eject when done
echo "Starting rip process... (This may take 10-20 minutes)"
sudo docker exec -u arm arm abcde -d /dev/sr0 -c /etc/arm/config/abcde.conf -N -x

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "=== Rip Completed Successfully ==="
    # The -x flag in abcde should handle eject, but we force it here just in case
    eject /dev/sr0
else
    echo "=== Rip FAILED (Exit Code: $EXIT_CODE) ==="
    echo "Check output above for errors."
fi
