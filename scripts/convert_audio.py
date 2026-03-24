import os
import subprocess
import time
import sys
import shutil

# Paths
TARGET_LIST = "/home/mrbinary/projects/Digital_Jukebox/reference/conversion_targets.txt"
SSD_TEMP = "/mnt/transcode/temp_conversion.flac"
CONTAINER_TEMP = "/home/arm/media/transcode/temp_conversion.flac"
LOG_FILE = "/home/mrbinary/projects/Digital_Jukebox/reference/conversion_history.log"

# Set to True to delete original files after successful conversion
DELETE_ORIGINAL = True 

def log(message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    formatted_msg = f"[{timestamp}] {message}"
    print(formatted_msg)
    try:
        with open(LOG_FILE, "a") as f:
            f.write(formatted_msg + "\n")
    except Exception as e:
        print(f"Failed to write to log file: {e}")

def convert_file(host_source_path):
    if not os.path.exists(host_source_path):
        log(f"SKIPPED: File not found: {host_source_path}")
        return False

    base_path = os.path.splitext(host_source_path)[0]
    target_flac_host = base_path + ".flac"
    
    container_source = host_source_path.replace("/mnt/storage/music", "/home/arm/music")

    if os.path.exists(target_flac_host):
        log(f"SKIPPED: Target already exists: {target_flac_host}")
        return True

    log(f"PROCESSING: {os.path.basename(host_source_path)}")
    
    if os.path.exists(SSD_TEMP):
        os.remove(SSD_TEMP)

    cmd = [
        "docker", "exec", "arm", "ffmpeg", "-i", container_source,
        "-y", "-hide_banner", "-loglevel", "error", 
        "-compression_level", "8", CONTAINER_TEMP
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0 and os.path.exists(SSD_TEMP):
            if os.path.getsize(SSD_TEMP) > 0:
                shutil.move(SSD_TEMP, target_flac_host)
                log(f"SUCCESS: Created {os.path.basename(target_flac_host)}")
                
                if DELETE_ORIGINAL:
                    os.remove(host_source_path)
                    log(f"DELETED: Original {os.path.basename(host_source_path)}")
                return True
            else:
                log(f"ERROR: Resulting file is empty for {host_source_path}")
        else:
            log(f"ERROR: Conversion failed for {host_source_path}")
            if result.stderr:
                log(f"STDERR: {result.stderr.strip()}")
    except Exception as e:
        log(f"EXCEPTION: {str(e)}")
    
    return False

def main():
    if not os.path.exists(TARGET_LIST):
        print(f"Error: Target list not found at {TARGET_LIST}")
        sys.exit(1)

    with open(TARGET_LIST, "r") as f:
        targets = [line.strip() for line in f if line.strip()]

    log(f"Starting conversion batch of {len(targets)} files...")
    
    success_count = 0
    fail_count = 0
    
    limit = None
    if len(sys.argv) > 1:
        try:
            limit = int(sys.argv[1])
            log(f"Test Mode: Limiting to {limit} files.")
            targets = targets[:limit]
        except ValueError:
            pass

    for path in targets:
        if convert_file(path):
            success_count += 1
        else:
            fail_count += 1
            
    log(f"Batch Complete. Success: {success_count}, Failed: {fail_count}")

if __name__ == "__main__":
    main()
