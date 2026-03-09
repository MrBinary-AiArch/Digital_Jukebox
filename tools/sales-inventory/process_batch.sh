#!/bin/bash
# Process a batch of sales inventory

INPUT_DIR="./batches"
OUTPUT_DIR="./archive"

for file in "$INPUT_DIR"/*.csv; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        python3 process_sales_batch.py "$file"
        mv "$file" "$OUTPUT_DIR/"
    fi
done
