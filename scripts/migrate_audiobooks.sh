#!/bin/bash
# Safety-First Audiobook Migration Script (Optimized for single password prompt)
# Targets remote TrueNAS: root@100.92.206.57:/mnt/<YOUR_POOL_NAME>/<YOUR_DATASET_NAME>/Media/AudioBooks/

REMOTE_TARGET="root@100.92.206.57:/mnt/<YOUR_POOL_NAME>/<YOUR_DATASET_NAME>/_Holding_Pen/Audiobooks_Return/"
LOG_FILE="/home/mrbinary/reports/audiobook_migration.log"
CLEANUP_FILE="/home/mrbinary/reports/cleanup_commands.sh"

# List of directories and files to migrate
SOURCES=(
    "/mnt/storage/music/library/Jon Krakauer"
    "/mnt/storage/music/library/MP3"
    "/mnt/storage/music/library/Minnesota Public Radio/Midday Podcast (Hour 1 with Gary Eichten"
    "/mnt/storage/music/library/Jack Campbell - The Lost Fleet 1 - 5"
    "/mnt/storage/music/library/Star Wars - Audio Book"
    "/mnt/storage/music/library/Douglas Adams"
    "/mnt/storage/music/library/Unsorted/Marcus Aurelius - Meditations"
    "/mnt/storage/music/library/Sokie Stackhouse Southern Vampire Mysteries"
)

# Initialize files
echo "=== Audiobook Migration Started: $(date) ===" | tee -a "$LOG_FILE"
echo "#!/bin/bash" > "$CLEANUP_FILE"

# Filter out non-existent sources to avoid rsync errors
VALID_SOURCES=()
for SRC in "${SOURCES[@]}"; do
    if [ -e "$SRC" ]; then
        VALID_SOURCES+=("$SRC")
        echo "rm -rf \"$SRC\"" >> "$CLEANUP_FILE"
    else
        echo "SKIPPING: $SRC (Not found)" | tee -a "$LOG_FILE"
    fi
done

if [ ${#VALID_SOURCES[@]} -eq 0 ]; then
    echo "No valid sources found. Exiting." | tee -a "$LOG_FILE"
    exit 0
fi

# Run ONE single rsync call for all valid sources to minimize password prompts
echo "PROCESSING: ${VALID_SOURCES[@]}" | tee -a "$LOG_FILE"

# rsync parameters optimized for TrueNAS ZFS/SMB ACLs:
# -r: recursive
# -t: preserve modification times
# -v: verbose
# -P: partial/progress (resumable)
# -z: compress during transfer
# --inplace: Write directly to final destination (prevents .file.XXXXXX mkstemp errors)
# --no-perms: Do not try to sync Linux permissions to ZFS ACLs
# --no-owner: Do not try to sync owner
# --no-group: Do not try to sync group
# --ignore-existing: skip files that already exist on TrueNAS
rsync -rtvPz --inplace --no-perms --no-owner --no-group --ignore-existing "${VALID_SOURCES[@]}" "$REMOTE_TARGET" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "SUCCESS: Migration successfully transferred or already exists." | tee -a "$LOG_FILE"
    chmod +x "$CLEANUP_FILE"
else
    echo "FAILURE: Migration encountered an error. Check log." | tee -a "$LOG_FILE"
fi

echo "=== Migration Cycle Finished: $(date) ===" | tee -a "$LOG_FILE"
echo "Review the log at: $LOG_FILE"
echo "Cleanup commands are staged in: $CLEANUP_FILE"
