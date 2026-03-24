import xml.etree.ElementTree as ET
import sys

file_path = "/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml"

try:
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Settings to apply
    tailscale_subnet = "100.64.0.0/10"
    local_subnet = "192.168.12.0/24"
    custom_url = "http://100.77.128.53:32400"

    # 1. Update allowedNetworks (comma separated list)
    current_allowed = root.get('allowedNetworks', '')
    networks = [n.strip() for n in current_allowed.split(',') if n.strip()]
    
    if tailscale_subnet not in networks:
        networks.append(tailscale_subnet)
    if local_subnet not in networks:
        networks.append(local_subnet)
    
    root.set('allowedNetworks', ",".join(networks))

    # 2. Set Custom Connection URL (CRITICAL for Plexamp discovery)
    root.set('customConnections', custom_url)

    # 3. Ensure publishing is enabled
    root.set('PublishServerOnPlexOnlineKey', '1')

    # Save
    tree.write(file_path, encoding='utf-8', xml_declaration=True)
    print("Successfully updated Plex Preferences.xml")

except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
