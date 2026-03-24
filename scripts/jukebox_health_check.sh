#!/bin/bash

# Digital Jukebox Health Check Script
# Version 1.3 (Centralized Logging Update)

LOG_FILE="/home/mrbinary/projects/Digital_Jukebox/logs/health_check.log"

{
echo "=========================================="
echo "   Digital Jukebox System Health Check    "
echo "=========================================="
date
echo ""

# 1. System Information
echo "[+] System Information"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
uptime
echo ""

# 2. Power & Shutdown History
echo "[+] Power & Shutdown History (Last 5)"
last reboot | head -n 5
echo ""
echo "Checking for unexpected shutdowns in logs..."
journalctl -b -1 -n 20 | grep -iE "power|voltage|shutdown|halt" || echo "No obvious power-loss errors in previous boot logs."
echo ""

# 3. Memory Usage
echo "[+] Memory Usage"
free -h
echo ""

# 4. Storage Status & SMART
echo "[+] Storage Status & SMART Health"
ROOT_USAGE=$(df -h / | awk 'NR==2 {print $5}')
echo "Root Filesystem Usage: $ROOT_USAGE"

if mountpoint -q /mnt/storage; then
    echo "SUCCESS: /mnt/storage is mounted."
    df -h /mnt/storage
    echo ""
    echo "--- SMART Health Status (/dev/sda) ---"
    if command -v smartctl &> /dev/null; then
        sudo smartctl -H /dev/sda | grep -E "test result|overall-health" || echo "SMART status unavailable."
    fi
else
    echo "CRITICAL: /mnt/storage is NOT mounted!"
fi
echo ""

# 5. Optical Drive Check
echo "[+] Optical Drive Check"
for DRIVE in /dev/sr0 /dev/sr1; do
    if [ -e "$DRIVE" ]; then
        echo "Optical Drive ($DRIVE) detected."
    else
        echo "ERROR: Optical Drive ($DRIVE) NOT detected."
    fi
done
echo ""

# 6. Docker Services
echo "[+] Docker Services"
if command -v docker &> /dev/null; then
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.State}}"
fi
echo ""

# 7. Network Connectivity
echo "[+] Network Connectivity"
if ping -c 3 8.8.8.8 &> /dev/null; then
    echo "Internet connectivity confirmed."
else
    echo "ERROR: No Internet connectivity."
fi

echo ""
echo "=========================================="
echo "           Health Check Complete          "
echo "=========================================="
echo -e "\n"
} >> "$LOG_FILE" 2>&1

# Also echo to console if not running in background
if [ -t 1 ]; then
    tail -n 60 "$LOG_FILE"
fi
