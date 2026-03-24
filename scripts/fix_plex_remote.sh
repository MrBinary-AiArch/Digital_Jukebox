#!/bin/bash
# Digital Jukebox - Fix Plex Remote Access (Tailscale)
# Adds Tailscale subnet to allowed networks and sets custom connection URLs.

PREFS_FILE="/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml"
BACKUP_FILE="${PREFS_FILE}.bak.$(date +%F_%T)"

# 1. Stop Plex
echo "Stopping Plex Container..."
docker stop plex

# 2. Backup Preferences
echo "Backing up Preferences.xml..."
cp "$PREFS_FILE" "$BACKUP_FILE"

# 3. Modify Preferences
# We use python for safer XML attribute editing than sed
python3 -c "
import xml.etree.ElementTree as ET
import os

file_path = '$PREFS_FILE'
tree = ET.parse(file_path)
root = tree.getroot()

# Define new settings
tailscale_net = '100.64.0.0/10'
local_net = '192.168.12.0/24'
custom_url = 'http://100.77.128.53:32400'

# Update allowedNetworks (List of IP addresses and networks that are allowed without auth)
# Actually, we probably don't want 'allowedNetworks' (no auth) for remote, just for detection.
# But adding the subnet prevents 'Indirect' connection issues.
current_allowed = root.get('allowedNetworks', '')
if tailscale_net not in current_allowed:
    new_allowed = f'{current_allowed},{tailscale_net},{local_net}'.strip(',')
    root.set('allowedNetworks', new_allowed)
    print(f'Updated allowedNetworks: {new_allowed}')

# Update customConnections (Critical for Tailscale/Remote)
root.set('customConnections', custom_url)
print(f'Set customConnections: {custom_url}')

# Ensure it is published
root.set('PublishServerOnPlexOnlineKey', '1')

tree.write(file_path, encoding='utf-8', xml_declaration=True)
"

# 4. Start Plex
echo "Starting Plex Container..."
docker start plex

echo "Plex Remote Access Fix Applied."
echo "Please instruct the user to restart the Plexamp app on their phone."
