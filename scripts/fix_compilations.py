import os
import shutil
import argparse

def fix_compilation(library_dir, target_album_name):
    print(f"Consolidating compilation album: {target_album_name}...")
    
    target_dir = os.path.join(library_dir, "Various Artists", target_album_name)
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
        print(f"Created target directory: {target_dir}")

    # Search the entire library for this album
    for artist in os.listdir(library_dir):
        if artist == "Various Artists":
            continue
        artist_path = os.path.join(library_dir, artist)
        if not os.path.isdir(artist_path):
            continue
            
        for album in os.listdir(artist_path):
            if album.lower().strip() == target_album_name.lower().strip():
                album_path = os.path.join(artist_path, album)
                print(f"Found source: {album_path}")
                
                # Move files from source to target
                for f in os.listdir(album_path):
                    src_file = os.path.join(album_path, f)
                    dest_file = os.path.join(target_dir, f)
                    
                    if os.path.exists(dest_file):
                        print(f"Skipping duplicate file: {f}")
                    else:
                        print(f"Moving {f} -> {target_dir}")
                        shutil.move(src_file, dest_file)
                
                # Try to remove the empty source album folder and its artist folder if empty
                try:
                    os.rmdir(album_path)
                    print(f"Removed empty source folder: {album_path}")
                    os.rmdir(artist_path)
                    print(f"Removed empty artist folder: {artist_path}")
                except OSError:
                    pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Consolidate fragmented compilation albums.")
    parser.add_argument("album", help="Album name to consolidate.")
    parser.add_argument("--dir", default="/mnt/storage/music/library", help="Library directory.")
    args = parser.parse_args()
    
    fix_compilation(args.dir, args.album)
