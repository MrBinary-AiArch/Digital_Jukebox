#!/bin/bash
# Apply Plex Remote Access Fix

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./scripts/plex_remote_apply.sh"
  exit 1
fi

echo "Stopping Plex..."
docker stop plex

echo "Backing up preferences..."
cp "/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml" "/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml.bak"

echo "Applying configuration changes..."
python3 /home/mrbinary/projects/Digital_Jukebox/scripts/plex_remote_config.py

echo "Starting Plex..."
docker start plex

echo "Done! Plexamp should now be able to find the server over Tailscale."
echo "Note: The user must have the Tailscale app CONNECTED on their Pixel 9."
