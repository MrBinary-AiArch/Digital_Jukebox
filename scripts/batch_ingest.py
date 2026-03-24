import os
import shutil
import sys

INGEST_DIR = "/mnt/storage/music/ingest"
BATCH_SIZE = 1000

def batch_loose_files():
    # Get all files in the root of ingest (excluding the directory itself)
    # We use os.scandir for better performance with many files
    files = []
    with os.scandir(INGEST_DIR) as it:
        for entry in it:
            if entry.is_file():
                files.append(entry.name)
    
    total_files = len(files)
    print(f"Total loose files to batch: {total_files}")
    
    if total_files == 0:
        print("No loose files found in root.")
        return

    # Sort files to ensure some consistency
    files.sort()
    
    for i in range(0, total_files, BATCH_SIZE):
        batch_num = (i // BATCH_SIZE) + 1
        batch_dir = os.path.join(INGEST_DIR, f"loose_batch_{batch_num:02d}")
        
        if not os.path.exists(batch_dir):
            os.makedirs(batch_dir)
            
        current_batch = files[i:i + BATCH_SIZE]
        print(f"Moving batch {batch_num} ({len(current_batch)} files)...")
        
        for filename in current_batch:
            src = os.path.join(INGEST_DIR, filename)
            dst = os.path.join(batch_dir, filename)
            try:
                shutil.move(src, dst)
            except Exception as e:
                print(f"Error moving {filename}: {e}")
                
    print("Batching complete.")

if __name__ == "__main__":
    batch_loose_files()
