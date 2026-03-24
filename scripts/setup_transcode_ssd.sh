#!/bin/bash
# Script to prepare the SSD (/dev/sda) for Plex Transcoding (Fixed)

# 1. Clear old signatures
wipefs -a /dev/sda

# 2. Create a new GPT partition table
parted -s /dev/sda mklabel gpt

# 3. Create a single partition using the whole drive
parted -s /dev/sda mkpart primary ext4 0% 100%

# 4. Refresh partitions and wait for /dev/sda1 to appear
udevadm settle
sleep 2

# 5. Format the new partition as ext4
mkfs.ext4 -F /dev/sda1

# 6. Create the mount point
mkdir -p /mnt/transcode

# 7. Get the UUID of the new partition
UUID=$(blkid -s UUID -o value /dev/sda1)

# 8. Add to /etc/fstab if it's not already there
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID /mnt/transcode ext4 defaults,noatime 0 2" >> /etc/fstab
fi

# 9. Reload systemd
systemctl daemon-reload

# 10. Mount the drive
mount /mnt/transcode

# 11. Set permissions for Plex (within container)
chmod 777 /mnt/transcode

echo "SSD (/dev/sda1) formatted and mounted to /mnt/transcode."
echo "UUID: $UUID"
