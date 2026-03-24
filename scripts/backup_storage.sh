#!/bin/bash
# Backup Script for Digital <YOUR_HOSTNAME>
# Backs up critical data from 3TB Storage, Docker Configs, and ARM Configs to the 4TB Backup Drive

LOG_FILE="/home/<YOUR_USER>/projects/Digital_<YOUR_HOSTNAME>/logs/storage_backup.log"
BACKUP_DEST="/mnt/backup"

{
echo "======================================================"
echo "STORAGE MIRROR STARTED - $(date)"
echo "======================================================"

# 1. Backup /mnt/storage (3TB Media) - Exclude lost+found
echo "Backing up /mnt/storage..."
rsync -av --delete --exclude 'lost+found' /mnt/storage/ "$BACKUP_DEST/storage_backup/"

# 2. Backup /home/<YOUR_USER>/docker (Docker Configs)
echo "Backing up Docker configurations..."
rsync -av --delete /home/<YOUR_USER>/docker/ "$BACKUP_DEST/docker_backup/"

# 3. Backup /home/<YOUR_USER>/arm_db (ARM Database)
echo "Backing up ARM database..."
rsync -av --delete /home/<YOUR_USER>/arm_db/ "$BACKUP_DEST/arm_db_backup/"

echo "======================================================"
echo "STORAGE MIRROR COMPLETED - $(date)"
echo "======================================================"
echo -e "\n"
} >> "$LOG_FILE" 2>&1
