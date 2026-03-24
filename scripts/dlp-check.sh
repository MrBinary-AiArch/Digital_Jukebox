#!/bin/bash

# Digital Jukebox DLP (Data Loss Prevention) Scanner
# This script scans a specified directory for sensitive patterns before public release.

TARGET_DIR="${1:-.}"
LOG_FILE="/home/mrbinary/reports/dlp_scan_$(date +%Y%m%d_%H%M%S).log"
EXIT_CODE=0

# Define patterns to flag (IPs, API Keys, Passwords)
PATTERNS=(
    "\\b10\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\b"
    "\\b192\\.168\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\b"
    "\\b100\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\b"
    "by5Cs8L92ysPKFPDZ32J" # Specific Plex Token
    "\\bmrbinary\\b"            # Local username
    "\\badmin\\b"               # Generic sensitive username
    "password="
    "SECRET="
    "KEY="
)

echo "--- Starting DLP Scan on: $TARGET_DIR ---" | tee "$LOG_FILE"

for PATTERN in "${PATTERNS[@]}"; do
    # Search specified directory, excluding .git and common noise
    MATCHES=$(grep -rE --exclude-dir=".git" --exclude-dir=".github" --exclude="dlp-check.sh" --exclude="README.md" "$PATTERN" "$TARGET_DIR" 2>/dev/null)
    
    if [ ! -z "$MATCHES" ]; then
        echo "FAIL: Found potential sensitive pattern '$PATTERN' in:" | tee -a "$LOG_FILE"
        echo "$MATCHES" | tee -a "$LOG_FILE"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -eq 0 ]; then
    echo "PASS: No sensitive patterns found in $TARGET_DIR." | tee -a "$LOG_FILE"
else
    echo "--- DLP SCAN FAILED ---" | tee -a "$LOG_FILE"
    echo "Scan log saved to: $LOG_FILE"
fi

exit $EXIT_CODE
