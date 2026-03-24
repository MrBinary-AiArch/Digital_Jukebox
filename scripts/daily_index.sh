#!/bin/bash
# Digital Jukebox File Indexer
# Generates a text-based index of critical system files and media.
# Scheduled to run daily via Cron.

INDEX_FILE="/home/mrbinary/projects/Digital_Jukebox/reference/file_index.txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "Starting Index Generation: $DATE"

# Initialize File
echo "# Digital Jukebox File Index" > "$INDEX_FILE"
echo "# Updated: $DATE" >> "$INDEX_FILE"
echo "# ---------------------------------------------------" >> "$INDEX_FILE"

# Function to append to index with a header
index_dir() {
    local dir=$1
    local name=$2
    if [ -d "$dir" ]; then
        echo "Indexing $name ($dir)..."
        echo "## SECTION: $name" >> "$INDEX_FILE"
        # Find all files, pruning heavy metadata directories for efficiency
        find "$dir" -xdev \
            \( -name ".git" -o -name "Metadata" -o -name "Cache" -o -name "MediaCover" -o -name "lost+found" \) -prune \
            -o -type f \
            -not -name '*.log' \
            -not -name '*.ldb' \
            -print >> "$INDEX_FILE" 2>/dev/null
    else
        echo "Skipping $name (Directory not found: $dir)"
    fi
}

# 1. Project Directory
index_dir "/home/mrbinary/projects/Digital_Jukebox" "Project Files"

# 2. Docker Configurations (Plex, ARM, etc.)
index_dir "/home/mrbinary/docker" "Docker Configs"

# 3. Media Storage (The Big One)
index_dir "/mnt/storage" "Media Library"

# 4. ARM Specifics
index_dir "/home/arm" "ARM Home"
index_dir "/opt/arm" "ARM Install"
index_dir "/etc/arm" "ARM Etc"

# 5. Plex specific (just Preferences for tokens, not the whole metadata db)
if [ -f "/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml" ]; then
    echo "/home/mrbinary/docker/plex/config/Library/Application Support/Plex Media Server/Preferences.xml" >> "$INDEX_FILE"
fi

echo "Index generation complete."
echo "Total Files Indexed: $(wc -l < "$INDEX_FILE")"
