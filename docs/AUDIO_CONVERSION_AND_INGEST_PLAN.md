# Action Plan: Audio Conversion & Ingest Cleanup

This document outlines the strategy for optimizing the Digital Jukebox music library by converting specific formats to FLAC and organizing the `ingest` directory.

## Phase 1: Audio Conversion (WAV & WMA to FLAC)

### Objective
Convert uncompressed (WAV) and less compatible (WMA) audio files to FLAC to save disk space (for WAV) and ensure broad device compatibility (for WMA) while preserving all available metadata.

### Target Files
- **WAV:** ~211 files (Space saving: ~40-50%)
- **WMA:** ~9,700 files (Compatibility improvement)
- **Note:** MP3 and M4A files will be left as-is to prevent unnecessary disk bloat.

### Technical Strategy
1. **Transcoding Workspace:** Use the 128GB OCZ SSD mounted at `/mnt/transcode` for all temporary processing to reduce wear on the primary storage and NVMe.
2. **Processing Engine:** Utilize `ffmpeg` via the ARM Docker container to leverage its built-in metadata handling and codecs.
3. **Verification Loop:** 
   - Convert source file to temporary FLAC on SSD.
   - Verify the FLAC file size and integrity.
   - Move verified FLAC to the source directory with matching filename.
   - Delete original only after successful move.

## Phase 2: Ingest Cleanup & Migration

### Objective
Empty the `/mnt/storage/music/ingest` folder by moving identified music to the permanent library, leaving only "home-made" or unidentified files for manual review.

### Strategy
1. **Automatic Sorting:** Use Lidarr's API or folder monitoring to identify and move recognized artists/albums to `/mnt/storage/music/library`.
2. **Batch Move:** Any folders clearly identified as "Artist/Album" that were missed by automation will be moved manually via script.
3. **Home-made Retention:** Files not matching any database or having non-standard naming will be left in `ingest` for the user to categorize.

## Todo List
- [x] Generate master list of target WAV/WMA files.
- [x] Create `convert_audio.py` processing script.
- [x] Perform test run on one WAV and one WMA folder.
- [x] Execute full library conversion. (Completed 2026-03-04)
- [ ] Update `file_index.txt` post-conversion.
- [ ] Run Lidarr "Library Import" on the ingest folder.
- [ ] Manually move remaining identified folders.
- [ ] Report final 'ingest' contents to user.
