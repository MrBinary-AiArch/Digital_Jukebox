import os
import shutil
import sys

INGEST_DIR = "/mnt/storage/music/ingest"
LIBRARY_DIR = "/mnt/storage/music/library"

def is_audio_file(filename):
    ext = os.path.splitext(filename)[1].lower()
    return ext in ['.mp3', '.flac', '.m4a', '.wma', '.wav', '.ogg']

def has_audio_files(directory):
    for root, dirs, files in os.walk(directory):
        if any(is_audio_file(f) for f in files):
            return True
    return False

def managed_move():
    if not os.path.exists(LIBRARY_DIR):
        os.makedirs(LIBRARY_DIR)

    # Get all top-level directories in ingest
    items = os.listdir(INGEST_DIR)
    
    move_count = 0
    skip_count = 0
    
    for item in items:
        item_path = os.path.join(INGEST_DIR, item)
        if not os.path.isdir(item_path):
            continue
            
        if item in ['failed_conversions', 'reference', 'scripts', 'reports']:
            continue
            
        # If the directory contains audio files (directly or in subdirs), it's a candidate
        if has_audio_files(item_path):
            # Check if it has a sub-directory structure (Artist/Album)
            # Or if it's just a bunch of files
            subdirs = [d for d in os.listdir(item_path) if os.path.isdir(os.path.join(item_path, d))]
            
            # If it has subdirs that contain audio, it's definitely an Artist folder
            artist_likely = False
            if subdirs:
                for subdir in subdirs:
                    if has_audio_files(os.path.join(item_path, subdir)):
                        artist_likely = True
                        break
            
            # Even if it doesn't have subdirs, if it has a lot of audio files, we'll move it
            # But let's be conservative and only move things that look like Artist/Album for now
            # Actually, most of the ingest is Artist/Album.
            
            if artist_likely:
                target_path = os.path.join(LIBRARY_DIR, item)
                
                # Handle existing artist folders in library
                if os.path.exists(target_path):
                    # Move subdirs individually
                    for subdir in subdirs:
                        subdir_path = os.path.join(item_path, subdir)
                        target_subdir = os.path.join(target_path, subdir)
                        if not os.path.exists(target_subdir):
                            try:
                                shutil.move(subdir_path, target_subdir)
                                print(f"Moved album: {item}/{subdir}")
                                move_count += 1
                            except Exception as e:
                                print(f"Error moving {subdir_path}: {e}")
                        else:
                            print(f"Skipped existing album: {item}/{subdir}")
                            skip_count += 1
                else:
                    try:
                        shutil.move(item_path, target_path)
                        print(f"Moved artist: {item}")
                        move_count += 1
                    except Exception as e:
                        print(f"Error moving {item_path}: {e}")
            else:
                print(f"Skipping flat directory: {item}")
                skip_count += 1
        else:
            print(f"Skipping directory with no audio: {item}")
            skip_count += 1
            
    print(f"Managed move complete. Moved: {move_count}, Skipped: {skip_count}")

if __name__ == "__main__":
    managed_move()
