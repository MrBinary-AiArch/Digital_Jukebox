import os
import shutil
import re

LIBRARY_ROOT = "/mnt/storage/music/library"
# Pattern to match: AlbumName_DiscID_YYYYMMDD_HHMMSS
# We want to group by everything before the last timestamp
FOLDER_PATTERN = re.compile(r"(.+)_([0-9]{8}_[0-9]{6})$")

def merge_folders():
    print(f"Scanning library: {LIBRARY_ROOT}")
    
    for artist in os.listdir(LIBRARY_ROOT):
        artist_path = os.path.join(LIBRARY_ROOT, artist)
        if not os.path.isdir(artist_path):
            continue
            
        # Map of {BaseName: [FullPaths]}
        groups = {}
        
        for album_folder in os.listdir(artist_path):
            match = FOLDER_PATTERN.match(album_folder)
            if match:
                base_name = match.group(1)
                full_path = os.path.join(artist_path, album_folder)
                if base_name not in groups:
                    groups[base_name] = []
                groups[base_name].append(full_path)
        
        # Process groups with more than one folder
        for base_name, paths in groups.items():
            if len(paths) > 1:
                # Sort by timestamp (in the path name) so we pick a consistent target
                paths.sort()
                target_dir = paths[0]
                source_dirs = paths[1:]
                
                print(f"\nMerging fragments for {artist} / {base_name}:")
                print(f"  Target: {os.path.basename(target_dir)}")
                
                for source in source_dirs:
                    print(f"  From:   {os.path.basename(source)}")
                    for item in os.listdir(source):
                        source_item = os.path.join(source, item)
                        target_item = os.path.join(target_dir, item)
                        
                        if not os.path.exists(target_item):
                            shutil.move(source_item, target_item)
                        else:
                            # If file exists, check size. If identical, we can delete the source
                            s_size = os.path.getsize(source_item)
                            t_size = os.path.getsize(target_item)
                            # 1% tolerance for metadata/tagging differences
                            if abs(s_size - t_size) < (t_size * 0.01):
                                os.remove(source_item)
                            else:
                                print(f"    Keeping {item} (significant size difference)")
                    
                    # Remove empty source dir
                    try:
                        if not os.listdir(source):
                            os.rmdir(source)
                        else:
                            print(f"    Warning: {source} still contains: {os.listdir(source)}")
                    except OSError as e:
                        print(f"    Error removing {source}: {e}")

if __name__ == "__main__":
    merge_folders()
    print("\nCleanup complete.")
