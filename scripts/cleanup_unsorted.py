import os
import shutil

def cleanup_unsorted(library_dir):
    unsorted_dir = os.path.join(library_dir, "Unsorted")
    if not os.path.exists(unsorted_dir):
        print("Unsorted directory not found.")
        return

    print(f"Scanning {unsorted_dir} for duplicates in the main library...")
    
    # Get all albums in the main library (Artist/Album)
    main_albums = {}
    for artist in os.listdir(library_dir):
        if artist == "Unsorted": continue
        artist_path = os.path.join(library_dir, artist)
        if not os.path.isdir(artist_path): continue
        
        for album in os.listdir(artist_path):
            album_path = os.path.join(artist_path, album)
            if not os.path.isdir(album_path): continue
            
            norm_name = album.lower().strip()
            if norm_name not in main_albums:
                main_albums[norm_name] = []
            
            # Count files in the main album
            files = os.listdir(album_path)
            main_albums[norm_name].append({
                'path': album_path,
                'file_count': len(files)
            })

    # Now check Unsorted albums
    for unsorted_album in os.listdir(unsorted_dir):
        unsorted_path = os.path.join(unsorted_dir, unsorted_album)
        if not os.path.isdir(unsorted_path): continue
        
        norm_name = unsorted_album.lower().strip()
        if norm_name in main_albums:
            # We found a match! 
            # If the main library version has >= files, we can safely delete the unsorted one.
            unsorted_files = os.listdir(unsorted_path)
            best_main = max(main_albums[norm_name], key=lambda x: x['file_count'])
            
            if best_main['file_count'] >= len(unsorted_files):
                print(f"DELETE (Duplicate): {unsorted_path} (Already in {best_main['path']})")
                shutil.rmtree(unsorted_path)
            else:
                print(f"NOT DELETING: {unsorted_path} has more files than {best_main['path']}")

if __name__ == "__main__":
    cleanup_unsorted("/mnt/storage/music/library")
