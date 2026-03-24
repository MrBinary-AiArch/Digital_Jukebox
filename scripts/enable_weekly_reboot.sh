#!/bin/bash
# Configure Weekly Auto-Reboot
# Schedule: Sundays at 06:00 UTC (Midnight CST)
# Purpose: Clear zombie processes and reset optical drive hardware state.

# Define the cron job (06:00 UTC = 00:00 CST / 01:00 CDT)
JOB="0 6 * * 0 /sbin/shutdown -r now"

# Check if the job already exists
if crontab -l 2>/dev/null | grep -q "/sbin/shutdown -r now"; then
    echo "✅ Weekly reboot is ALREADY scheduled."
else
    # Append the job to the current crontab
    (crontab -l 2>/dev/null; echo "$JOB") | crontab -
    echo "✅ Weekly reboot ENABLED: Sundays at 06:00 UTC."
fi

# Verify the list
echo "Current Cron Schedule:"
crontab -l
