#!/usr/bin/env bash
#
# prep_for_publish.sh
# Purpose: Automatically scrubs sensitive data (IPs, usernames, pool names)
# from all files in a given directory before pushing to a public repository.
#
# Usage: ./prep_for_publish.sh <target_directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target_directory>"
    echo "Example: $0 ../homelab_public_template/"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

echo "Scrubbing all files in ${TARGET_DIR}..."

# Array of sensitive strings and their replacements
declare -a SCRUB_LIST=(
    "<SYNOLOGY_IP>:<SYNOLOGY_IP>"
    "<TRUENAS_IP>:<TRUENAS_IP>"
    "<YOUR_POOL_NAME>:<YOUR_POOL_NAME>"
    "<YOUR_DATASET_NAME>:<YOUR_DATASET_NAME>"
    "<YOUR_USER>:<YOUR_USER>"
)

# Apply scrubbing using sed on all files
find "$TARGET_DIR" -type f | while read -r file; do
    for item in "${SCRUB_LIST[@]}"; do
        SEARCH="${item%%:*}"
        REPLACE="${item##*:}"
        
        # Use sed to replace in-place, ignoring case for pool names
        sed -i "s/${SEARCH}/${REPLACE}/gi" "$file"
    done
done

echo "Done! Directory $TARGET_DIR has been scrubbed."
