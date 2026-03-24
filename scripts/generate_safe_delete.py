import os
import argparse

def generate_safe_delete(root_dir):
    """
    Identifies MP3/M4A/Compressed folders that can be safely deleted because a
    corresponding FLAC version exists with at least the same number of tracks.
    """
    album_map = {}
    deletion_candidates = []
    
    # 1. First-Pass: Walk the library to collect all album names and their locations
    print(f"Analyzing {root_dir} for safe deletions...")
    
    # Traverse the library: root/Artist/Album
    for artist_name in os.listdir(root_dir):
        artist_path = os.path.join(root_dir, artist_name)
        if not os.path.isdir(artist_path):
            continue
            
        for album_name in os.listdir(artist_path):
            album_path = os.path.join(artist_path, album_name)
            if not os.path.isdir(album_path):
                continue
            
            norm_album = album_name.lower().strip()
            
            try:
                files = os.listdir(album_path)
            except PermissionError:
                continue

            flac_files = [f for f in files if f.lower().endswith('.flac')]
            compressed_files = [f for f in files if f.lower().endswith(('.mp3', '.m4a', '.wma', '.wav'))]
            
            if norm_album not in album_map:
                album_map[norm_album] = []
                
            album_map[norm_album].append({
                'artist': artist_name,
                'album': album_name,
                'path': album_path,
                'flac_count': len(flac_files),
                'compressed_count': len(compressed_files),
                'total_files': len(files)
            })

    # 2. Evaluate for "Safe Delete"
    for norm_name, occurrences in album_map.items():
        if len(occurrences) < 2:
            continue
            
        # Separate into FLAC-heavy and non-FLAC
        flac_versions = [o for o in occurrences if o['flac_count'] > 0]
        non_flac_versions = [o for o in occurrences if o['flac_count'] == 0 and o['compressed_count'] > 0]
        
        if not flac_versions or not non_flac_versions:
            continue
            
        # Find the "best" FLAC version (most tracks)
        best_flac = max(flac_versions, key=lambda x: x['flac_count'])
        
        for cand in non_flac_versions:
            # SAFETY CRITERIA:
            # 1. FLAC version must have >= tracks than candidate version
            # 2. Artist names should be similar
            a1 = cand['artist'].lower().replace('_', ' ').strip()
            a2 = best_flac['artist'].lower().replace('_', ' ').strip()
            
            # Substring match or one is Unsorted
            artist_match = (a1 in a2 or a2 in a1 or "unsorted" in a1 or "unsorted" in a2)
            
            if best_flac['flac_count'] >= cand['compressed_count'] and artist_match:
                deletion_candidates.append({
                    'delete_path': cand['path'],
                    'keep_path': best_flac['path'],
                    'reason': f"FLAC version has {best_flac['flac_count']} tracks vs {cand['compressed_count']} in compressed folder."
                })

    # 3. Write Dry Run Report
    report_path = "/home/mrbinary/reports/safe_delete_dry_run.txt"
    with open(report_path, "w", encoding='utf-8') as f:
        f.write("=== Jukebox Phase 1: Safe Delete Dry Run ===\n")
        f.write(f"Candidate Folders for Deletion: {len(deletion_candidates)}\n")
        f.write("============================================\n\n")
        
        if not deletion_candidates:
            f.write("No safe deletion candidates found matching strict criteria.\n")
        else:
            for item in deletion_candidates:
                f.write(f"DELETE: {item['delete_path']}\n")
                f.write(f"KEEP:   {item['keep_path']}\n")
                f.write(f"REASON: {item['reason']}\n")
                f.write("-" * 40 + "\n")
            
    print(f"Dry run complete. Found {len(deletion_candidates)} candidates.")
    print(f"Review the list at: {report_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate safe delete list.")
    parser.add_argument("--dir", default="/mnt/storage/music/library", help="Library directory.")
    args = parser.parse_args()
    generate_safe_delete(args.dir)
