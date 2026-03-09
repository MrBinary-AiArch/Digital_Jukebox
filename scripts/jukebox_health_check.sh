#!/bin/bash

# Digital Jukebox Health Check Script
# Version 1.2 (Power Stability Update)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Digital Jukebox System Health Check    ${NC}"
echo -e "${GREEN}==========================================${NC}"
date
echo ""

# 1. System Information
echo -e "${YELLOW}[+] System Information${NC}"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
uptime
echo ""

# 2. Power & Shutdown History
echo -e "${YELLOW}[+] Power & Shutdown History (Last 5)${NC}"
last reboot | head -n 5
echo -e "
${YELLOW}Checking for unexpected shutdowns in logs...${NC}"
journalctl -b -1 -n 20 | grep -iE "power|voltage|shutdown|halt" || echo "No obvious power-loss errors in previous boot logs."
echo ""

# 3. Memory Usage
echo -e "${YELLOW}[+] Memory Usage${NC}"
free -h
echo ""

# 4. Storage Status & SMART
echo -e "${YELLOW}[+] Storage Status & SMART Health${NC}"
# Check Root FS
ROOT_USAGE=$(df -h / | awk 'NR==2 {print $5}')
echo "Root Filesystem Usage: $ROOT_USAGE"

# Check Main Storage Mount (/mnt/storage)
if mountpoint -q /mnt/storage; then
    echo -e "${GREEN}SUCCESS: /mnt/storage is mounted.${NC}"
    df -h /mnt/storage
    
    echo -e "
--- SMART Health Status (/dev/sda) ---"
    if command -v smartctl &> /dev/null; then
        sudo smartctl -H /dev/sda | grep -E "test result|overall-health" || echo -e "${RED}SMART status unavailable. Check drive type.${NC}"
    else
        echo -e "${RED}smartmontools not installed. Run: sudo apt install smartmontools${NC}"
    fi
else
    echo -e "${RED}CRITICAL: /mnt/storage is NOT mounted!${NC}"
    echo "Checking physical block devices..."
    lsblk | grep -E "sd|nvme"
fi
echo ""

# 5. Optical Drive Check
echo -e "${YELLOW}[+] Optical Drive Check${NC}"
if [ -e /dev/sr0 ]; then
    echo -e "${GREEN}Optical Drive (/dev/sr0) detected.${NC}"
else
    echo -e "${RED}ERROR: Optical Drive (/dev/sr0) NOT detected.${NC}"
fi
echo ""

# 6. Docker Services
echo -e "${YELLOW}[+] Docker Services${NC}"
if command -v docker &> /dev/null; then
    docker ps -a --format "table {{.Names}}	{{.Status}}	{{.State}}"
else
    echo -e "${RED}Docker is not installed or not in PATH.${NC}"
fi
echo ""

# 7. Network Connectivity
echo -e "${YELLOW}[+] Network Connectivity${NC}"
if ping -c 3 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}Internet connectivity confirmed.${NC}"
else
    echo -e "${RED}ERROR: No Internet connectivity.${NC}"
fi

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}           Health Check Complete          ${NC}"
echo -e "${GREEN}==========================================${NC}"
