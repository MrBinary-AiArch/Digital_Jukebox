#!/bin/bash
# Deep Diagnosis for Optical Drive & Disc
# Usage: sudo ./debug_optical.sh

DRIVE="/dev/sr0"

echo "=== 1. Host System Disc Identification ==="
echo "Checking udev properties for media type..."
udevadm info -q all -n $DRIVE | grep "ID_CDROM_MEDIA"

echo -e "
=== 2. Drive Capability Check ==="
# Check read speed/status using hdparm if available, or just simple status
if command -v hdparm &> /dev/null; then
    hdparm -I $DRIVE | grep "Model"
    hdparm -C $DRIVE
else
    echo "hdparm not installed."
fi

echo -e "
=== 3. Container-Side Disc Query (cd-discid) ==="
# This tool is used by abcde to calculate the CDDB ID.
docker exec arm cd-discid $DRIVE

echo -e "
=== 4. Container-Side TOC Query (cdparanoia) ==="
# cdparanoia is the ripping backend. -Q queries the Table of Contents.
# -v: verbose
# -s: search for drive
docker exec arm cdparanoia -vQ -d $DRIVE

echo -e "
=== 5. Mounting Test ==="
# Attempt to mount as ISO9660 (Data) to see if it's actually a data disc
mkdir -p /tmp/cdrom_test
mount -t iso9660 -o ro $DRIVE /tmp/cdrom_test 2>/tmp/mount_error
if [ $? -eq 0 ]; then
    echo "Disc MOUNTED successfully as DATA (ISO9660)."
    ls -F /tmp/cdrom_test
    umount /tmp/cdrom_test
else
    echo "Disc failed to mount as DATA. (Expected for pure Audio CDs)"
    cat /tmp/mount_error
fi
rmdir /tmp/cdrom_test
