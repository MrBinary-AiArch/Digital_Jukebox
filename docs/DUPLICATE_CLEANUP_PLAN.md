# Jukebox Library De-Duplication & Quality Optimization Plan

This document outlines the three-phase strategy for cleaning up the Digital Jukebox music library to eliminate duplicate albums, prioritize high-quality FLAC files over legacy MP3s, and fix fragmented compilation albums.

## Phase 1: Quality-First Automated Cleanup (FLAC vs. MP3)
**Goal:** Identify and remove lower-quality MP3 folders where a complete, high-quality FLAC version of the same album already exists.

- [x] **Step 1.1:** Generate a "Dry Run" deletion script that lists all MP3 folders slated for removal.
- [x] **Step 1.2:** User review and approval of the deletion list.
- [x] **Step 1.3:** Execute the deletion and verify Plex correctly reflects the changes (no "unavailable" files).

## Phase 2: Library Consolidation (Unsorted & Mismatched Names)
**Goal:** Move high-quality FLAC albums from the `/Unsorted/` directory into their proper Artist folders and reconcile slight naming discrepancies (e.g., `Rubn Blades` vs `Rubén_Blades`).

- [x] **Step 2.1:** Move confirmed FLAC albums from `/mnt/storage/music/library/Unsorted/` to their target Artist folders (e.g., *Duets II*, *A Wonderful World*).
- [x] **Step 2.2:** Merge folders where the same album is split due to minor character differences (e.g., `&` vs `_`).
- [ ] **Step 2.3:** Trigger a Plex "Scan Library Files" to update the database. (Partial: Triggered post-Phase 3 move).

## Phase 3: Compilation & "Various Artists" Repair
**Goal:** Group fragmented compilation albums (currently split into individual artist folders) into a single `Various Artists` directory to ensure they appear as a single album in Plex.

- [x] **Step 3.1:** Identify highly fragmented albums (e.g., *Q's Jook Joint*, *Singe Die Verse Gottes*, *Swingers*).
- [x] **Step 3.2:** Consolidate these tracks into `/mnt/storage/music/library/Various Artists/[Album Name]/`.
- [ ] **Step 3.3:** Use `metaflac` or `id3v2` to ensure the "Album Artist" tag is set to "Various Artists".

---
*Status: Phase 1 In-Progress (Audit Complete).*
