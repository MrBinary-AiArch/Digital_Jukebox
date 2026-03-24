#!/bin/bash
# Script to prepare the 4TB Hard Drive (/dev/sdb) for backup
# Format to ext4 and mount at /mnt/backup

# 1. Create a new GPT partition table
parted -s /dev/sdb mklabel gpt

# 2. Create a single partition using the whole drive
parted -s /dev/sdb mkpart primary ext4 0% 100%

# 3. Format the new partition as ext4
mkfs.ext4 -F /dev/sdb1

# 4. Create the mount point
mkdir -p /mnt/backup

# 5. Get the UUID of the new partition
UUID=$(blkid -s UUID -o value /dev/sdb1)

# 6. Add to /etc/fstab if it's not already there
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID /mnt/backup ext4 defaults 0 2" >> /etc/fstab
fi

# 7. Mount the drive
mount /mnt/backup

echo "4TB Hard Drive (/dev/sdb1) formatted and mounted to /mnt/backup."
echo "UUID: $UUID"
