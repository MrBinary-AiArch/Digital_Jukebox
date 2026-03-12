## Configuration Status
- **[2026-01-19]**: Hardware confirmed: HP EliteDesk 800 G3 Tower.
- **[2026-01-19]**: OS selected: Ubuntu Server (Headless) to prioritize ARM hardware control.
- **[2026-01-19]**: Storage strategy: 1x 3TB WD Red Plus for music and PC backups.
- **[2026-01-19]**: Hardware shipped via FedEx (397902060026). Expected arrival: 2026-01-23.

## Active Paths
- **Raw Rip Landing**: /mnt/storage/music/ingest (Deprecated - Direct to Library)
- **Organized Library**: /mnt/storage/music/library
- **Client Backup Root**: /mnt/storage/backups/pc_backups

## Session Update [2026-01-19]
- **Shipping**: Confirmed FedEx tracking #397902060026 for HP EliteDesk 800 G3, arriving 2026-01-23.
- **Preparation**: Issued "Clean Exit" protocol. User advised to prepare Ubuntu Server ISO, static IP reservation, and test media.

## Session Update [2026-01-25]
- **Hardware Identification**: Recorded Serial No. (2UA8162F6D), Product No. (Y1B39AV), BID, and FeatureByte from the HP EliteDesk 800 G3 TWR for warranty, BIOS, and driver support.
- **License Retrieval**: Extracted OEM Windows Product Key from BIOS (NP2GB-HT4QJ-GXGFR-8XQMY-RC2KC) prior to OS wipe.
- **Storage Initialization**: Successfully cleared inactive RAID metadata on /dev/sda. Partitioned as GPT and formatted as ext4. 3TB drive now mounted at /mnt/storage. fstab updated with UUID 1c22e389-99a7-46fc-b9df-b23e893c1575.
- **ARM Deployment**: Installed Automatic Ripping Machine via Docker. Configured arm.yaml and abcde.conf for zero-touch FLAC ripping. Resolved UID/GID permission issues on /home/arm. System is ready for first disc test.
- **Hardware Acceleration**: Confirmed Intel QuickSync support on i5-7600 within the ARM container.

## Session Update [2026-01-25] - OS Installation
- **Installation Profile**: Selected "minimized" Ubuntu Server base to reduce bloat for headless appliance.
- **Storage Layout**: Configured NVMe for OS (LVM, no encryption). 3TB HDD reserved for later formatting.
- **Network**: Confirmed `eno1` (18:60:24:7e:17:af) as primary interface. Manual Netplan fix applied to resolve DHCP issues.
- **Current IP**: LOCAL_IP_ADDRESS
- **Status**: SSH active. Essential tools (nano, curl, etc.) installed. Ready for storage drive troubleshooting.

## Session Update [2026-01-25] - Application Deployment
- **Ingestion Pipeline**: ARM successfully ripped test media ("Diana Krall - Love Scenes") to FLAC. Permissions and volume mappings corrected to route files to `/mnt/storage/music/ingest`.
- **Media Server**: Plex Media Server deployed via Docker (Hardware Acceleration enabled). Library mapped to `/mnt/storage/music/library`.
- **Library Management**: Lidarr deployed via Docker. Initial configuration (naming formats, quality profiles) begun. Connection to Plex established.

## Session Update [2026-01-25] - Remote Access
- **Service**: Tailscale installed for secure remote connectivity.
- **Method**: Standard Linux curl installer.
- **Tailscale IP**: TAILSCALE_IP_ADDRESS
- **Objective**: Enable administration and Plex access from outside the local subnet.

## Session Update [2026-01-25] - Stack Simplification
- **Architecture Change**: REMOVED Lidarr from the software stack.
- **Rationale**: Lidarr introduced manual gating (import approval) which conflicted with the "Zero-Touch" appliance goal.
- **New Workflow**: ARM configured to rip directly to `/mnt/storage/music/library`. Plex handles all organization and metadata display.

## Session Update [2026-01-25] - Pipeline Finalization & Hardware Expansion
- **Zero-Touch Workflow**: Finalized ARM Docker configuration to rip directly to `/mnt/storage/music/library`. Verified file permissions and Plex visibility.
- **Data Consolidation**: Migrated legacy rips from `/ingest` to `/library` and removed the staging directory.
- **Dual-Drive Config**: Prepared configuration for secondary optical drive (`/dev/sr1`). Updated `arm.yaml` to allow 2 concurrent transcodes and updated Docker Compose to map the new device.
- **Local DNS**: Installed `avahi-daemon` to enable `digitaljukebox.local` mDNS resolution on the LAN.
- **Documentation**: Created `JUKEBOX_USER_MANUAL.md`, a simplified one-page guide for the end-user.

## Session Update [2026-03-12] (Drive Lockout Recovery)

### Key Activities
- **Fault Diagnosis:** Investigated "both drives stuck" report. Identified that ARM was repeatedly bailing out on /dev/sr0 and failed to start on /dev/sr1 due to persistent database locks.
- **Root Cause Identified:** 
  1. Failed jobs (123, 132) were marked as 'fail' but 'ejected=0', causing ARM to believe the discs were still present.
  2. The 'system_drives' table still had 'job_id_current' pointing to these failed jobs, blocking new hardware scans.
- **Resolution:**
  - Manually updated the internal database to set 'ejected=1' for failed jobs.
  - Cleared 'job_id_current' for both drives in the 'system_drives' table.
  - Restarted the ARM container.
  - Manually triggered rips using 'python3 main.py -d sr0' (notably requires device name *without* the '/dev/' prefix).
- **Current Status:** 
  - **Drives:** Both drives successfully released and ripping new media.
- **Documentation:** 
  - Created 'Troubleshooting_Drive/' directory.
  - Authored 'TROUBLESHOOTING_DRIVE.md' detailing hardware mapping, stability caps (12x), and the specific SQL commands to clear lockout states.

### GitHub & Repository Status
- **Public Template:** Updated with the new Troubleshooting guide.

### Decisions & Facts
- **SQL Lockout Recovery:** Established a new SOP for clearing "Zombie" drive states by zeroing out 'system_drives.job_id_current'.
- **Manual Trigger Syntax:** Confirmed that 'main.py' prepends '/dev/' automatically, so triggers must use 'sr0'/'sr1'.
