import os
import argparse
import datetime
import shutil

def find_duplicates(root_dir):
    quality_clashes = {} # {album_key: {base_filename: [extensions_found]}}
    report_path = "/home/mrbinary/projects/Digital_Jukebox/logs/quality_clash_report.txt"

    print(f"Scanning for Quality Clashes (FLAC vs MP3) in {root_dir}...")
    
    for root, dirs, files in os.walk(root_dir):
        if ".git" in root or "@eaDir" in root: continue
        
        album_files = {} # {base_name: [(ext, full_path)]}
        
        for f in files:
            if not f.lower().endswith(('.mp3', '.flac', '.m4a', '.wav')): continue
            
            base_name, ext = os.path.splitext(f)
            # Normalize base name (strip track numbers etc for better matching)
            # but keep it simple for now: just the base filename
            
            if base_name not in album_files:
                album_files[base_name] = []
            album_files[base_name].append((ext.lower(), os.path.join(root, f)))

        # Check this specific folder for clashes
        for base_name, occurrences in album_files.items():
            if len(occurrences) > 1:
                exts = [occ[0] for x, (occ) in (occurrences)] # Incorrect logic in original file? 
                # Let's stick to literal content from template as requested.
                exts = [occ[0] for occ in occurrences]
                if '.flac' in exts and '.mp3' in exts:
                    if root not in quality_clashes:
                        quality_clashes[root] = []
                    quality_clashes[root].append({
                        'file': base_name,
                        'paths': [occ[1] for occ in occurrences]
                    })

    with open(report_path, "w", encoding='utf-8') as f:
        f.write(f"=== Jukebox Quality Clash Audit (FLAC vs MP3) [{datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}] ===\n")
        f.write(f"Folders with Clashes: {len(quality_clashes)}\n")
        f.write("========================================================\n\n")
        
        for folder, clashes in quality_clashes.items():
            f.write(f"FOLDER: {folder}\n")
            for clash in clashes:
                f.write(f"  CLASH: {clash['file']}\n")
                for p in clash['paths']:
                    f.write(f"    -> {p}\n")
            f.write("-" * 60 + "\n")

    print(f"Audit complete! Found {len(quality_clashes)} folders with FLAC/MP3 clashes.")
    print(f"Detailed QUALITY report saved to: {report_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find FLAC vs MP3 quality clashes.")
    parser.add_argument("--dir", default="/mnt/storage/music/library", help="Library directory.")
    args = parser.parse_args()
    find_duplicates(args.dir)
