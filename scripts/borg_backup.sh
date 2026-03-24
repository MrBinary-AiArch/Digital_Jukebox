#!/bin/bash
# BorgBackup Script for Digital Jukebox
# Provides deduplicated, versioned backups with encryption.

# --- Configuration ---
REPOSITORY="/mnt/backup/borg_repo"
LOG_FILE="/home/mrbinary/projects/Digital_Jukebox/logs/borg_backup.log"
PASSPHRASE_FILE="/home/mrbinary/.borg_passphrase"

# Source the passphrase
if [ -f "$PASSPHRASE_FILE" ]; then
    export BORG_PASSPHRASE=$(cat "$PASSPHRASE_FILE")
else
    echo "ERROR: Passphrase file $PASSPHRASE_FILE not found!" | tee -a "$LOG_FILE"
    exit 1
fi

# --- Helper Functions ---
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# --- 1. Start Backup ---
log_info "Starting Borg Backup..."
SNAPSHOT_NAME="$(hostname)-$(date '+%Y-%m-%d-%H%M%S')"

# Backup critical directories
borg create --stats --show-rc --compression lz4 \
    "$REPOSITORY::$SNAPSHOT_NAME" \
    /mnt/storage \
    /home/mrbinary/docker \
    /home/mrbinary/arm_db \
    /home/mrbinary/scripts \
    /home/mrbinary/projects \
    --exclude '/mnt/storage/lost+found' \
    >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log_info "Borg Backup successfully created snapshot: $SNAPSHOT_NAME"
else
    log_error "Borg Backup failed to create snapshot."
fi

# --- 2. Prune Old Backups (Retention Policy) ---
log_info "Pruning old backups (Retention: 7 daily, 4 weekly, 6 monthly)..."
borg prune --list --show-rc --keep-daily=7 --keep-weekly=4 --keep-monthly=6 "$REPOSITORY" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log_info "Borg Prune completed successfully."
else
    log_error "Borg Prune failed."
fi

# --- 3. Compact the Repository ---
log_info "Compacting repository to reclaim space..."
borg compact "$REPOSITORY" >> "$LOG_FILE" 2>&1

log_info "Borg Maintenance Cycle Finished."
echo "------------------------------------------------------" >> "$LOG_FILE"
