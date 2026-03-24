#!/bin/bash
# Notify Plex to scan the Music library
# Runs inside the ARM container.

PLEX_URL="http://100.77.128.53:32400"
PLEX_TOKEN="by5Cs8L92ysPKFPDZ32J"
LIBRARY_ID="1"

echo "Notifying Plex to refresh library section $LIBRARY_ID..."

# Refresh the entire library section
curl -s --max-time 10 -o /dev/null -w "%{http_code}" -X GET "$PLEX_URL/library/sections/$LIBRARY_ID/refresh?X-Plex-Token=$PLEX_TOKEN"

if [ $? -eq 0 ]; then
    echo "Plex notification sent successfully."
else
    echo "Failed to notify Plex."
fi
