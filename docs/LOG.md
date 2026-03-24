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
eference` path usage for `scp` commands in documentation.ebox

## Session Update [2026-01-25] - Session Closure
- **System Status**: Online & Operational.
- **Access Points**:
    - **Local**: `http://digitaljukebox.local`
    - **Remote**: `TAILSCALE_IP_ADDRESS` (Tailscale)
- **Services**: Plex (32400), ARM (8080), SSH (22).
- **Handover**: User Manual generated. System ready for dual-drive expansion and unsupervised operation.

## Session Update [2026-01-26] - Advanced Features & Troubleshooting
- **Manual Metadata**: Deployed **MusicBrainz Picard** (Docker: `mikenye/picard`) to port 5800. Enabled web-based manual tagging for "Unknown" discs.
- **Inventory Reporting**: Created `generate_inventory.sh` to export a CSV manifest of the library for valuation/resale purposes.
- **Zero-Touch Playback**: Deployed **MiniDLNA** (Docker: `vladgh/minidlna`) to port 8200.
    - **Purpose**: Allows Roku Media Player to play music without Plex authentication.
    - **Security**: Configured to share `/music` ONLY. Home videos are hidden.
    - **Status**: Verified functional via VLC and Web Interface.

## Session Update [2026-01-26] - Session Closure
- **System Status**: Fully Operational.
- **New Services**: Picard (5800), MiniDLNA (8200).
- **Deliverables**: `Sales_Inventory.csv` generation script, Dual-mode playback (Secure Plex + Open DLNA).
- **Next Actions**: Dual-drive hardware upgrade (pending availability).

## Session Update [2026-01-26] - On-Site Verification
- **Local IP Address**: `LOCAL_IP_ADDRESS` (Primary LAN)
- **Tailscale IP**: `TAILSCALE_IP_ADDRESS` (Remote Admin)
- **Internet Connectivity**: Confirmed (0% packet loss to 8.8.8.8).
- **Storage Status**: `/dev/sda1` (3TB) confirmed mounted at `/mnt/storage`.
- **Docker Status**: All services (Plex, ARM, MiniDLNA, Picard) verified "Up".
- **Rip Test**: SUCCESS. Disc recognized, processed, and auto-ejected.
- **Plex Visibility**: Confirmed. New media appeared in library automatically.
- **Thermals**: Excellent. CPU idle/load temps between 25°C - 30°C.
- **Status**: SYSTEM FULLY OPERATIONAL. Handover complete.

## Session Update [2026-01-26] - Hardware Verification & Network Strategy
- **WiFi Status**: Confirmed ABSENT. No internal M.2 card or USB adapter detected.
- **Ethernet**: Intel I219-LM (PCIe) confirmed as sole network interface.
- **Expansion Potential**: Motherboard verified to support M.2 2230, but requires antenna kit.
- **Advisory**: "Zero-Touch" protocol dictates using **M.2 Intel Desktop Kit** (e.g., AX200) over USB adapters if wireless is ever required, to ensure native Linux kernel support.
- **Operational Status**: Maintaining wired Ethernet (`eno1`) for maximum reliability.

## Session Update [2026-01-26] - Final Site Exit
- **Obj
