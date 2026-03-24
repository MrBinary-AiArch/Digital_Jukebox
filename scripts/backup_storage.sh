#!/bin/bash
# Backup Script for Digital Jukebox
# Backs up critical data from 3TB Storage, Docker Configs, and ARM Configs to the 4TB Backup Drive

LOG_FILE="/home/mrbinary/projects/Digital_Jukebox/logs/storage_backup.log"
BACKUP_DEST="/mnt/backup"

{
echo "======================================================"
echo "STORAGE MIRROR STARTED - $(date)"
echo "======================================================"

# 1. Backup /mnt/storage (3TB Media) - Exclude lost+found
echo "Backing up /mnt/storage..."
rsync -av --delete --exclude 'lost+found' /mnt/storage/ "$BACKUP_DEST/storage_backup/"

# 2. Backup /home/mrbinary/docker (Docker Configs)
echo "Backing up Docker configurations..."
rsync -av --delete /home/mrbinary/docker/ "$BACKUP_DEST/docker_backup/"

# 3. Backup /home/mrbinary/arm_db (ARM Database)
echo "Backing up ARM database..."
rsync -av --delete /home/mrbinary/arm_db/ "$BACKUP_DEST/arm_db_backup/"

echo "======================================================"
echo "STORAGE MIRROR COMPLETED - $(date)"
echo "======================================================"
echo -e "\n"
} >> "$LOG_FILE" 2>&1
