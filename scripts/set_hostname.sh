#!/bin/bash
# Update Hostname to 'jukebox'
# This script sets the hostname and updates the hosts file.

NEW_HOSTNAME="jukebox"
OLD_HOSTNAME=$(hostname)

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./set_hostname.sh"
  exit 1
fi

echo "Changing hostname from '$OLD_HOSTNAME' to '$NEW_HOSTNAME'..."

# 1. Update /etc/hostname
echo "$NEW_HOSTNAME" > /etc/hostname

# 2. Update /etc/hosts
sed -i "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts

# 3. Apply Hostname Change
hostnamectl set-hostname "$NEW_HOSTNAME"

# 4. Restart Networking/Avahi (mDNS)
systemctl restart avahi-daemon

echo "Hostname updated successfully!"
echo "New Local Address: http://$NEW_HOSTNAME.local:8080/"
echo "Please restart your session or reconnect if SSH fails."
