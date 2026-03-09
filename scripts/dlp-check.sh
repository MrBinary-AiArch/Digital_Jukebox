#!/bin/bash

# Digital Jukebox DLP (Data Loss Prevention) Scanner
# This script scans the repository for sensitive patterns before public release.

EXIT_CODE=0

# Define patterns to flag (IPs, API Keys, Passwords)
# Flagging: 10.x.x.x, 192.168.x.x, 100.x.x.x (Tailscale), API Keys, and literal "password"
PATTERNS=(
    "10\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
    "192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
    "100\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
    "by5Cs8L92ysPKFPDZ32J" # Specific Plex Token
    "mrbinary"            # Local username
    "admin"               # Generic sensitive username
    "password="
    "SECRET="
    "KEY="
)

echo "--- Starting DLP Scan ---"

for PATTERN in "${PATTERNS[@]}"; do
    # Search all files, excluding .git, workflows, and the script itself
    # We also exclude README.md because it contains placeholders for the user.
    MATCHES=$(grep -rE --exclude-dir=".git" --exclude-dir=".github" --exclude="dlp-check.sh" --exclude="README.md" "$PATTERN" .)
    
    if [ ! -z "$MATCHES" ]; then
        echo "FAIL: Found potential sensitive pattern '$PATTERN' in files:"
        echo "$MATCHES"
        EXIT_CODE=1
    fi
done

if [ $EXIT_CODE -eq 0 ]; then
    echo "PASS: No sensitive patterns found."
else
    echo "--- DLP SCAN FAILED ---"
    echo "Action required: Scrub the flagged data before pushing."
fi

exit $EXIT_CODE
