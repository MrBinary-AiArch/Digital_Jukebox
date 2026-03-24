import os
import unicodedata
import sys

def sanitize_name(name):
    # Normalize unicode characters to decompose into base character + accent
    normalized = unicodedata.normalize('NFKD', name)
    # Filter out the accent marks and keep only ASCII
    ascii_name = normalized.encode('ascii', 'ignore').decode('ascii')
    
    # Replace common troublesome characters with underscores
    for char in ['?', '*', ':', '"', '<', '>', '|', '\\', '/', '#', '%', '&', '{', '}', '$', '!', '@', '+', '=']:
        ascii_name = ascii_name.replace(char, '_')
    
    # Trim leading/trailing whitespace
    ascii_name = ascii_name.strip()
    
    # If the name becomes empty after stripping, just use an underscore
    if not ascii_name:
        ascii_name = "_"
        
    return ascii_name

def rename_recursive(root_path):
    # We walk bottom-up so we rename files before their parent directories
    for root, dirs, files in os.walk(root_path, topdown=False):
        # Rename files first
        for name in files:
            sanitized = sanitize_name(name)
            if sanitized != name:
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, sanitized)
                
                # Handle potential name collisions
                if os.path.exists(new_path):
                    count = 1
                    base, ext = os.path.splitext(sanitized)
                    while os.path.exists(f"{os.path.join(root, base)}_{count}{ext}"):
                        count += 1
                    new_path = f"{os.path.join(root, base)}_{count}{ext}"
                
                try:
                    os.rename(old_path, new_path)
                    print(f"Renamed file: {name} -> {os.path.basename(new_path)}")
                except Exception as e:
                    print(f"Error renaming file {old_path}: {e}")

        # Rename directories
        for name in dirs:
            sanitized = sanitize_name(name)
            if sanitized != name:
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, sanitized)
                
                # Handle potential name collisions
                if os.path.exists(new_path):
                    count = 1
                    while os.path.exists(f"{new_path}_{count}"):
                        count += 1
                    new_path = f"{new_path}_{count}"
                
                try:
                    os.rename(old_path, new_path)
                    print(f"Renamed dir: {name} -> {os.path.basename(new_path)}")
                except Exception as e:
                    print(f"Error renaming dir {old_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_dir = " ".join(sys.argv[1:])
    else:
        target_dir = "/mnt/storage/music/ingest"
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        sys.exit(1)
        
    print(f"Sanitizing filenames in {target_dir}...")
    try:
        rename_recursive(target_dir)
        print("Sanitization complete.")
    except Exception as e:
        print(f"Fatal error: {e}")
