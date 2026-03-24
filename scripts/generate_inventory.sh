#!/bin/bash
# Digital Jukebox - Inventory Export Script
# Extracts Artist, Album, and Folder Path for valuation

OUTPUT="/mnt/storage/music/Sales_Inventory.csv"

echo "Artist,Album,Folder_Path" > "$OUTPUT"

find /mnt/storage/music/library -mindepth 2 -maxdepth 2 -type d | while read -r dir; do
    # Get the folder name (Album)
    ALBUM=$(basename "$dir")
    # Get the parent folder name (Artist)
    ARTIST=$(basename "$(dirname "$dir")")
    
    # Clean up commas to avoid CSV errors
    CLEAN_ARTIST=$(echo "$ARTIST" | sed 's/,//g')
    CLEAN_ALBUM=$(echo "$ALBUM" | sed 's/,//g')
    
    echo "$CLEAN_ARTIST,$CLEAN_ALBUM,\"$dir\"" >> "$OUTPUT"
done

echo "Inventory complete. File saved to: $OUTPUT"
