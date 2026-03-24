#!/bin/bash
# Hardware and Firmware Inspection Script
# Saves output to /home/mrbinary/reports/hardware_inspection_report.txt

REPORT_FILE="/home/mrbinary/projects/Digital_Jukebox/logs/hardware_inspection_report.txt"

{
    echo "======================================================"
    echo "HARDWARE INSPECTION REPORT - $(date)"
    echo "======================================================"
    echo ""

    echo "--- 1. FIRMWARE UPDATES (fwupdmgr) ---"
    echo "Refreshing firmware metadata..."
    fwupdmgr refresh --force
    echo "Checking for updates..."
    fwupdmgr get-updates
    echo ""

    echo "--- 2. 4TB HARD DRIVE HEALTH (/dev/sdb) ---"
    smartctl -a /dev/sdb
    echo ""

    echo "--- 3. SSD HEALTH (/dev/sda - OCZ-VERTEX4) ---"
    smartctl -a /dev/sda
    echo ""

    echo "--- 4. NVMe SSD HEALTH (/dev/nvme0n1) ---"
    smartctl -a /dev/nvme0n1
    echo ""

    echo "--- 5. WIFI CARD DETAILS (lspci) ---"
    lspci -v -s 02:00.0
    echo ""

    echo "--- 6. BLOCK DEVICES (lsblk) ---"
    lsblk -f
    echo ""

} >> "$REPORT_FILE" 2>&1

echo -e "\n" >> "$REPORT_FILE"
echo "Inspection complete. Report saved to: $REPORT_FILE"
